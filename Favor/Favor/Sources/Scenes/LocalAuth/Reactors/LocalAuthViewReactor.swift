//
//  LocalAuthViewReactor.swift
//  Favor
//
//  Created by 이창준 on 6/29/23.
//

import OSLog

import FavorKit
import ReactorKit
import RxCocoa
import RxFlow

public final class LocalAuthViewReactor: Reactor, Stepper {

  // MARK: - Properties

  public var initialState: State
  public let steps = PublishRelay<Step>()
  private let location: LocalAuthLocation
  private let keychain = KeychainManager()

  private let targetPassword: String?

  public enum Action {
    case biometricAuthNeedsChecked
    case keypadDidSelected(FavorNumberKeypadCellModel)
    case localAuthSecceed
  }

  public enum Mutation {
    case pulseLocalAuthPrompt(Bool)
    case appendInput(Int)
    case removeLastInput
    case resetInput
  }

  public struct State {
    @Pulse var pulseLocalAuthPrompt: Bool = false
    var inputs: [KeypadInput] = Array(repeating: KeypadInput(data: nil, isLastInput: false), count: 4)
  }

  // MARK: - Initializer

  init(_ location: LocalAuthLocation) {
    self.initialState = State()
    self.location = location
    if case let LocalAuthLocation.settingsConfirmNew(password) = location {
      self.targetPassword = password
    } else {
      self.targetPassword = nil
    }
  }

  // MARK: - Functions

  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .biometricAuthNeedsChecked:
      return .empty()

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

          switch self.location {
          case .launch:
            return self.handleLaunchInput(with: key)
          case .settingsCheckOld:
            return self.handleCheckOldInput(with: key)
          case .settingsNew:
            return self.handleCheckNewInput(with: key)
          case .settingsConfirmNew:
            return self.handleCheckConfirmNewInput(with: key)
          }
        }
        return .just(.appendInput(keyNumber))

      // 특수기호가 입력됐을 때
      case .keyImage(let keyImage):
        guard keyImage == .favorIcon(.erase) else { return .empty() }
        return .just(.removeLastInput)
      }

    case .localAuthSecceed:
      os_log(.debug, "Local Auth Succeed!")
      return .empty()
    }
  }

  public func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .pulseLocalAuthPrompt(let isPromptNeeded):
      newState.pulseLocalAuthPrompt = isPromptNeeded

    case .appendInput(let inputNumber):
      guard let emptyIdx = newState.inputs.firstIndex(where: { $0.data == nil }) else { return state }
      newState.inputs[emptyIdx].data = inputNumber
      newState.inputs[emptyIdx].isLastInput = true
      if emptyIdx - 1 >= 0 {
        newState.inputs[emptyIdx - 1].isLastInput = false
      }

    case .removeLastInput:
      guard let lastIdx = state.inputs.lastIndex(where: { $0.data != nil }) else { return state }
      newState.inputs[lastIdx].isLastInput = false
      newState.inputs[lastIdx].data = nil

    case .resetInput:
      newState.inputs = [
        KeypadInput(isLastInput: false),
        KeypadInput(isLastInput: false),
        KeypadInput(isLastInput: false),
        KeypadInput(isLastInput: false)
      ]
    }

    return newState
  }
}

// MARK: - Privates

private extension LocalAuthViewReactor {
  /// 앱 실행 시 암호 입력이 완료됐을 때
  func handleLaunchInput(with key: String) -> Observable<Mutation> {
    if self.validateOldInput(key) { // 맞다면 dismiss
      self.steps.accept(AppStep.localAuthIsComplete)
      return .empty()
    } else {  // 틀리다면 다시
      HapticManager.haptic(style: .heavy)
      return .just(.resetInput)
    }
  }

  /// 암호 변경이 필요한 경우 이전 암호 입력이 완료됐을 때
  func handleCheckOldInput(with key: String) -> Observable<Mutation> {
    if self.validateOldInput(key) {
      self.steps.accept(AppStep.localAuthIsRequired(.settingsNew))
      return .empty()
    } else {
      HapticManager.haptic(style: .heavy)
      return .just(.resetInput)
    }
  }

  /// 새 암호가 필요한 경우 암호 입력이 완료됐을 때
  func handleCheckNewInput(with key: String) -> Observable<Mutation> {
    self.steps.accept(AppStep.localAuthIsRequired(.settingsConfirmNew(key)))
    return .just(.resetInput)
  }

  /// 새 암호가 필요한 경우 암호 확인 입력이 완료됐을 때
  func handleCheckConfirmNewInput(with key: String) -> Observable<Mutation> {
    guard
      let keyData = key.data(using: .utf8),
      let targetPassword = self.targetPassword
    else { return .empty() }

    if key == targetPassword {
      do {
        try self.keychain.set(value: keyData, account: KeychainManager.Accounts.localAuth.rawValue)
        UserInfoStorage.isLocalAuthEnabled = true
        self.steps.accept(AppStep.localAuthIsComplete)
        return .just(.resetInput)
      } catch {
        return .error(error)
      }
    } else {
      HapticManager.haptic(style: .heavy)
      return .just(.resetInput)
    }
  }

  /// 입력된 암호와 설정된 암호를 대조합니다.
  /// - Returns: 입력된 암호와 설정된 암호의 동일 여부 `Bool`
  func validateOldInput(_ key: String) -> Bool {
    // 암호를 저장된 암호와 대조하고
    guard let localAuth = try? self.keychain.get(account: KeychainManager.Accounts.localAuth.rawValue) else {
      fatalError("There is no keypass set for local auth.")
    }
    guard let localAuthString = String(data: localAuth, encoding: .utf8) else {
      fatalError("Failed to decoded keychain data.")
    }
    return key == localAuthString
  }
}
