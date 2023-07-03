//
//  AuthNewPasswordViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/03/04.
//

import OSLog

import FavorKit
import FavorNetworkKit
import ReactorKit
import RxCocoa
import RxFlow

public class AuthNewPasswordViewReactor: Reactor, Stepper {

  // MARK: - Constants

  public enum FlowLocation {
    case auth, settings
  }

  // MARK: - Properties

  public var initialState: State
  public var steps = PublishRelay<Step>()
  private let location: FlowLocation

  // Global States
  let oldPasswordValidate = BehaviorRelay<ValidationResult>(value: .empty)
  let passwordValidate = BehaviorRelay<ValidationResult>(value: .empty)
  let confirmPasswordValidate = BehaviorRelay<ValidationResult>(value: .empty)

  public enum Action {
    case oldPasswordTextFieldDidUpdate(String)
    case newPasswordTextFieldDidUpdate(String)
    case confirmNewPasswordTextFieldDidUpdate(String)
    case nextFlowRequested
  }

  public enum Mutation {
    case updateOldPassword(String)
    case updateOldPasswordValidationResult(ValidationResult)
    case updatePassword(String)
    case updatePasswordValidationResult(ValidationResult)
    case updateConfirmPassword(String)
    case updateConfirmPasswordValidationResult(ValidationResult)
    case validateDoneButton(Bool)
  }

  public struct State {
    var oldPassword: String = ""
    var oldPasswordValidationResult: ValidationResult = .empty
    var password: String = ""
    var passwordValidationResult: ValidationResult = .empty
    var confirmPassword: String = ""
    var confirmPasswordValidationResult: ValidationResult = .empty
    var isDoneButtonEnabled: Bool = false
  }

  // MARK: - Initializer

  init(_ location: FlowLocation) {
    self.initialState = State()
    self.location = location
  }

  // MARK: - Functions

  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .oldPasswordTextFieldDidUpdate(let oldPassword):
      let oldPasswordValidate = AuthValidationManager(type: .password).validate(oldPassword)
      self.oldPasswordValidate.accept(oldPasswordValidate)
      return .concat([
        .just(.updateOldPassword(oldPassword)),
        .just(.updateOldPasswordValidationResult(oldPasswordValidate))
      ])

    case .newPasswordTextFieldDidUpdate(let password):
      let passwordValidate = AuthValidationManager(type: .password).validate(password)
      self.passwordValidate.accept(passwordValidate)
      let confirmPasswordValidate = AuthValidationManager(type: .confirmPassword).confirm(
        password,
        with: self.currentState.confirmPassword
      )
      self.confirmPasswordValidate.accept(confirmPasswordValidate)
      return .concat([
        .just(.updatePassword(password)),
        .just(.updatePasswordValidationResult(passwordValidate)),
        .just(.updateConfirmPasswordValidationResult(confirmPasswordValidate))
      ])

    case .confirmNewPasswordTextFieldDidUpdate(let confirmPassword):
      let confirmPasswordValidate = AuthValidationManager(type: .confirmPassword).confirm(
        confirmPassword,
        with: self.currentState.password
      )
      self.confirmPasswordValidate.accept(confirmPasswordValidate)
      return .concat([
        .just(.updateConfirmPassword(confirmPassword)),
        .just(.updateConfirmPasswordValidationResult(confirmPasswordValidate))
      ])

    case .nextFlowRequested:
      os_log(.debug, "Done button or keyboard done button did tap.")
      if self.currentState.isDoneButtonEnabled {
        return self.requestNewPassword()
          .asObservable()
          .flatMap { _ -> Observable<Mutation> in
            self.steps.accept(AppStep.newPasswordIsComplete)
            return .empty()
          }
      }
      return .empty()
    }
  }

  public func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
    let combineValidationsMutation: Observable<Mutation> = Observable.combineLatest(
      self.oldPasswordValidate,
      self.passwordValidate,
      self.confirmPasswordValidate,
      resultSelector: { oldPasswordValidate, passwordValidate, confirmPasswordValidate in
        switch self.location {
        case .auth:
          return .validateDoneButton(passwordValidate == .valid && confirmPasswordValidate == .valid)
        case .settings:
          let isValid = {
            oldPasswordValidate == .valid &&
            passwordValidate == .valid &&
            confirmPasswordValidate == .valid &&
            self.currentState.oldPassword != self.currentState.password
          }()
          return .validateDoneButton(isValid)
        }
      })
    return Observable.of(mutation, combineValidationsMutation).merge()
  }

  public func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .updateOldPassword(let oldPassword):
      newState.oldPassword = oldPassword

    case .updateOldPasswordValidationResult(let oldPasswordValidate):
      newState.oldPasswordValidationResult = oldPasswordValidate

    case .updatePassword(let password):
      newState.password = password

    case .updatePasswordValidationResult(let passwordValidate):
      newState.passwordValidationResult = passwordValidate

    case .updateConfirmPassword(let confirmPassword):
      newState.confirmPassword = confirmPassword

    case .updateConfirmPasswordValidationResult(let confirmPasswordValidate):
      newState.confirmPasswordValidationResult = confirmPasswordValidate

    case .validateDoneButton(let isNextButtonEnabled):
      newState.isDoneButtonEnabled = isNextButtonEnabled
    }

    return newState
  }
}

// MARK: - Privates

private extension AuthNewPasswordViewReactor {
  // TODO: 서버 비밀번호 변경 구현 후 적용
  func requestNewPassword() -> Single<Bool> {
    let networking = UserNetworking()
    return Single<Bool>.create { single in
      single(.success(true))

      return Disposables.create {
        //
      }
    }
  }
}
