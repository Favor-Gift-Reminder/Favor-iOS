//
//  LocalAuthViewReactor.swift
//  Favor
//
//  Created by 이창준 on 6/29/23.
//

import OSLog
import UIKit

import DeviceKit
import FavorKit
import ReactorKit
import RxCocoa
import RxFlow


// 암호 인증 / 생체 인증
// authenticate: 암호 확인
// - 암호 인증 or 생체 인증
// askCurrent: 암호 변경을 위한 현재 암호 확인
// - 암호 인증 or 생체 인증
// askNew: 새 암호 입력
// - 암호 입력
// confirmNew: 새 암호 확인
// - 암호 입력 and 생체 인증(Optional)
// disable: 암호 삭제를 위한 암호 확인
// - 암호 인증 or 생체 인증
public final class LocalAuthViewReactor: Reactor, Stepper {
  typealias DescriptionMessage = LocalAuthViewController.DescriptionMessage

  // MARK: - Properties

  public var initialState: State
  public let steps = PublishRelay<Step>()
  public let localAuthRequest: LocalAuthRequest
  private let keychain = KeychainManager()

  private let targetPassword: String?

  public enum Action {
    case keypadDidSelected(FavorNumberKeypadCellModel)
    case biometricPopupDidFinish(Bool)
    case biometricAuthDidFinish(Bool)
  }

  public enum Mutation {
    case pulseBiometricAuthPrompt(Bool)
    case pulseBiometricAuth(Bool)
    case appendInput(Int)
    case resetInput
    case announceWrongPassword
  }

  public struct State {
    /// 생체 인증 프롬프트
    @Pulse var biometricAuthPromptPulse: Bool = false
    /// 생체 인증
    @Pulse var biometricAuthPulse: Bool = false
    var inputs: [KeypadInput] = Array(repeating: KeypadInput(data: nil, isLastInput: false), count: 4)
    var description: DescriptionMessage
  }

  // MARK: - Initializer

  init(_ request: LocalAuthRequest, description: DescriptionMessage) {
    self.initialState = State(
      description: description
    )
    self.localAuthRequest = request
    if case let LocalAuthRequest.confirmNew(password, _) = request {
      self.targetPassword = password
    } else {
      self.targetPassword = nil
    }
  }

  // MARK: - Functions

  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .keypadDidSelected(let keypad):
      switch keypad {
        // 숫자가 입력됐을 때
      case .keyString(let keyString):
        guard let keyNumber = Int(keyString) else { return .empty() }
        let currentInputs = self.currentState.inputs
        
        // 마지막 입력일 때
        if currentInputs.filter({ $0.data != nil }).count == currentInputs.count - 1 {
          var finalInput = currentInputs.dropLast()
          finalInput.append(KeypadInput(data: keyNumber, isLastInput: true))
          let key = Array(finalInput).combinedValue
          
          switch self.localAuthRequest {
          case .authenticate:
            return self.handleAuthenticateInput(with: key)
          case .askCurrent:
            return self.handleAskCurrentInput(with: key)
          case .askNew:
            return self.handleAskNewInput(with: key)
          case .confirmNew:
            return self.handleConfirmNewInput(with: key)
          case .disable:
            return self.handleDisable(with: key)
          }
        }
        return .just(.appendInput(keyNumber))
        
        // 특수기호가 입력됐을 때
      case .keyImage(let keyImage):
        switch keyImage {
        case UIImage(systemName: "faceid")!, UIImage(systemName: "touchid")!:
          return .just(.pulseBiometricAuth(true))
        default:
          return .empty()
        }

      case .emptyKey:
        return .empty()
      }

    case .biometricPopupDidFinish(let isConfirmed):
      UserInfoStorage.isBiometricAuthEnabled = isConfirmed
      if isConfirmed {
        return .just(.pulseBiometricAuth(true))
      } else {
        self.steps.accept(AppStep.localAuthIsComplete)
        return .empty()
      }

    case .biometricAuthDidFinish(let isSuccess):
      switch self.localAuthRequest {
      case .authenticate(let resultHandler):
        if isSuccess {
          do {
            try resultHandler(nil)
          } catch {
            os_log(.error, "\(error)")
          }
          self.steps.accept(AppStep.localAuthIsComplete)
        }
        
      case .askCurrent(let resultHandler):
        if isSuccess {
          self.steps.accept(AppStep.localAuthIsRequired(.askNew(resultHandler)))
        }

      case .askNew: // no bioauth
        break

      case .confirmNew(_, let resultHandler):
        if isSuccess {
          do {
            try resultHandler(nil)
          } catch {
            os_log(.error, "\(error)")
          }
        } else {
          UserInfoStorage.isBiometricAuthEnabled = false
        }
        self.steps.accept(AppStep.localAuthIsComplete)

      case .disable(let resultHandler):
        if isSuccess {
          do {
            try resultHandler(nil)
            self.steps.accept(AppStep.localAuthIsComplete)
          } catch {
            os_log(.error, "\(error)")
          }
        }
      }
      return .empty()
    }
  }

  public func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .pulseBiometricAuthPrompt(let isPromptNeeded):
      newState.biometricAuthPromptPulse = isPromptNeeded

    case .pulseBiometricAuth(let isAuthNeeded):
      newState.biometricAuthPulse = isAuthNeeded

    case .appendInput(let inputNumber):
      guard let emptyIdx = newState.inputs.firstIndex(where: { $0.data == nil }) else { return state }
      newState.inputs[emptyIdx].data = inputNumber
      newState.inputs[emptyIdx].isLastInput = true
      if emptyIdx - 1 >= 0 {
        newState.inputs[emptyIdx - 1].isLastInput = false
      }

    case .resetInput:
      newState.inputs = [
        KeypadInput(isLastInput: false),
        KeypadInput(isLastInput: false),
        KeypadInput(isLastInput: false),
        KeypadInput(isLastInput: false)
      ]

    case .announceWrongPassword:
      newState.description = DescriptionMessage(
        description: "암호가 일치하지 않습니다.",
        isError: true
      )
    }

    return newState
  }
}

// MARK: - Privates

private extension LocalAuthViewReactor {
  /// 현재 암호를 묻는 입력이 완료됐을 때
  func handleAuthenticateInput(with key: String) -> Observable<Mutation> {
    if self.validateCurrentInput(key) { // 맞다면 dismiss
      if case let LocalAuthRequest.authenticate(resultHandler) = self.localAuthRequest {
        do {
          try resultHandler(nil)
        } catch {
          os_log(.error, "\(error)")
        }
      }
      self.steps.accept(AppStep.localAuthIsComplete)
      return .empty()
    } else {  // 틀리다면 다시
      HapticManager.haptic(style: .heavy)
      return .concat([
        .just(.announceWrongPassword),
        .just(.resetInput)
      ])
    }
  }

  /// 암호 변경이 필요한 경우 이전 암호 입력이 완료됐을 때
  func handleAskCurrentInput(with key: String) -> Observable<Mutation> {
    if self.validateCurrentInput(key) {
      os_log(.debug, "🔐 Password match!")
      if case let LocalAuthRequest.askCurrent(resultHandler) = self.localAuthRequest {
        self.steps.accept(AppStep.localAuthIsRequired(.askNew(resultHandler)))
      }
      return .just(.resetInput)
    } else {
      os_log(.debug, "🔒 Password miss!")
      HapticManager.haptic(style: .heavy)
      return .concat([
        .just(.announceWrongPassword),
        .just(.resetInput)
      ])
    }
  }

  /// 새 암호가 필요한 경우 암호 입력이 완료됐을 때
  func handleAskNewInput(with key: String) -> Observable<Mutation> {
    if case let LocalAuthRequest.askNew(resultHandler) = self.localAuthRequest {
      self.steps.accept(AppStep.localAuthIsRequired(.confirmNew(key, resultHandler)))
    }
    return .just(.resetInput)
  }

  /// 새 암호가 필요한 경우 암호 확인 입력이 완료됐을 때
  func handleConfirmNewInput(with key: String) -> Observable<Mutation> {
    guard
      let keyData = key.data(using: .utf8),
      let targetPassword = self.targetPassword
    else { return .empty() }

    if key == targetPassword {
      if case let LocalAuthRequest.confirmNew(_, resultHandler) = self.localAuthRequest {
        do {
          try resultHandler(keyData)
        } catch {
          os_log(.error, "\(error)")
        }
      }

      // 생체 인증 Prompt
      if UserInfoStorage.isBiometricAuthEnabled {
        self.steps.accept(AppStep.localAuthIsComplete)
        return .just(.resetInput)
      } else {
        return .concat([
          .just(.resetInput),
          .just(.pulseBiometricAuthPrompt(true))
        ])
      }
    } else {
      HapticManager.haptic(style: .heavy)
      return .concat([
        .just(.resetInput),
        .just(.announceWrongPassword)
      ])
    }
  }

  /// 암호를 제거할 경우 입력이 완료됐을 때
  func handleDisable(with key: String) -> Observable<Mutation> {
    if self.validateCurrentInput(key) {
      if case let LocalAuthRequest.disable(resultHandler) = self.localAuthRequest {
        do {
          try resultHandler(nil)
        } catch {
          os_log(.error, "\(error)")
        }
      }
      self.steps.accept(AppStep.localAuthIsComplete)
      return .empty()
    } else {
      HapticManager.haptic(style: .heavy)
      return .just(.resetInput)
    }
  }

  /// 입력된 암호와 설정된 암호를 대조합니다.
  /// - Returns: 입력된 암호와 설정된 암호의 동일 여부 `Bool`
  func validateCurrentInput(_ key: String) -> Bool {
    guard let localAuth = try? self.keychain.get(account: KeychainManager.Accounts.localAuth.rawValue) else {
      fatalError("There is no keypass set for local auth.")
    }
    guard let localAuthString = String(data: localAuth, encoding: .utf8) else {
      fatalError("Failed to decoded keychain data.")
    }
    return key == localAuthString
  }
}
