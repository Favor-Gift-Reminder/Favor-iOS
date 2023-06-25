//
//  AuthNewPasswordViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/03/04.
//

import OSLog

import FavorKit
import ReactorKit
import RxCocoa
import RxFlow

public final class AuthNewPasswordViewReactor: Reactor, Stepper {

  // MARK: - Properties

  public var initialState: State
  public var steps = PublishRelay<Step>()

  // Global States
  let passwordValidate = BehaviorRelay<ValidationResult>(value: .empty)
  let confirmPasswordValidate = BehaviorRelay<ValidationResult>(value: .empty)

  public enum Action {
    case passwordTextFieldDidUpdate(String)
    case confirmPasswordTextFieldDidUpdate(String)
    case nextFlowRequested
  }

  public enum Mutation {
    case updatePassword(String)
    case updatePasswordValidationResult(ValidationResult)
    case updateConfirmPassword(String)
    case updateConfirmPasswordValidationResult(ValidationResult)
    case validateDoneButton(Bool)
  }

  public struct State {
    var password: String = ""
    var passwordValidationResult: ValidationResult = .empty
    var confirmPassword: String = ""
    var confirmPasswordValidationResult: ValidationResult = .empty
    var isDoneButtonEnabled: Bool = false
  }

  // MARK: - Initializer

  init() {
    self.initialState = State()
  }


  // MARK: - Functions

  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .nextFlowRequested:
      os_log(.debug, "Done button or keyboard done button did tap.")
      if self.currentState.isDoneButtonEnabled {
//        self.steps.accept(<#T##event: Step##Step#>)
      }
      return .empty()

    case .passwordTextFieldDidUpdate(let password):
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

    case .confirmPasswordTextFieldDidUpdate(let confirmPassword):
      let confirmPasswordValidate = AuthValidationManager(type: .confirmPassword).confirm(
        confirmPassword,
        with: self.currentState.password
      )
      self.confirmPasswordValidate.accept(confirmPasswordValidate)
      return .concat([
        .just(.updateConfirmPassword(confirmPassword)),
        .just(.updateConfirmPasswordValidationResult(confirmPasswordValidate))
      ])
    }
  }

  public func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
    let combineValidationsMutation: Observable<Mutation> = Observable.combineLatest(
      self.passwordValidate,
      self.confirmPasswordValidate,
      resultSelector: { passwordValidate, confirmPasswordValidate in
        if passwordValidate == .valid && confirmPasswordValidate == .valid {
          return .validateDoneButton(true)
        } else {
          return .validateDoneButton(false)
        }
      })
    return Observable.of(mutation, combineValidationsMutation).merge()
  }

  public func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
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
