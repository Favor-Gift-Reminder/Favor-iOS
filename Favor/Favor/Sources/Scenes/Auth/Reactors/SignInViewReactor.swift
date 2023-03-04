//
//  SignInViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/01/12.
//

import OSLog
import UIKit

import ReactorKit
import RxCocoa
import RxFlow

final class SignInViewReactor: Reactor, Stepper {
  
  // MARK: - Properties
  
  var initialState: State
  var steps = PublishRelay<Step>()

  // Global States
  let emailValidate = BehaviorRelay<ValidationResult>(value: .empty)
  let passwordValidate = BehaviorRelay<ValidationResult>(value: .empty)
  
  enum Action {
    case viewDidLoad
    case emailDidUpdate(String)
    case emailDidEndOnExit
    case passwordDidUpdate(String)
    case passwordDidEndOnExit
    case nextFlowRequested
    case findPasswordButtonDidTap
  }
  
  enum Mutation {
    case updateEmail(String)
    case updateEmailValidationResult(ValidationResult)
    case updatePassword(String)
    case updatePasswordValidationResult(ValidationResult)
    case validateSignInButton(Bool)
  }
  
  struct State {
    var email: String = ""
    var emailValidationResult: ValidationResult = .empty
    var password: String = ""
    var passwordValidationResult: ValidationResult = .empty
    var isSignInButtonEnabled: Bool = false
  }
  
  // MARK: - Initializer
  
  init() {
    self.initialState = State()
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      os_log(.debug, "View did load.")
      return .empty()

    case .emailDidUpdate(let email):
      os_log(.debug, "Email TextField did update: \(email)")
      let emailVaildate = AuthValidationManager(type: .email).validate(email)
      return .concat([
        .just(.updatePassword(email)),
        .just(.updateEmailValidationResult(emailVaildate))
      ])

    case .emailDidEndOnExit:
      os_log(.debug, "Email TextField did end on exit.")
      return .empty()

    case .passwordDidUpdate(let password):
      os_log(.debug, "Password TextField did update: \(password)")
      let passwordValidate = AuthValidationManager(type: .password).validate(password)
      return .concat([
        .just(.updatePassword(password)),
        .just(.updatePasswordValidationResult(passwordValidate))
      ])

    case .passwordDidEndOnExit:
      os_log(.debug, "Password TextField did end on exit.")
      return .empty()

    case .nextFlowRequested:
      os_log(.debug, "Sign in button did tap.")
      return .empty()

    case .findPasswordButtonDidTap:
      os_log(.debug, "Find password button did tap.")
      self.steps.accept(AppStep.findPasswordIsRequired)
      return .empty()
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .updateEmail(let email):
      newState.email = email

    case .updateEmailValidationResult(let emailValidate):
      newState.emailValidationResult = emailValidate

    case .updatePassword(let password):
      newState.password = password

    case .updatePasswordValidationResult(let passwordValidate):
      newState.passwordValidationResult = passwordValidate

    case .validateSignInButton(let isNextButtonEnabled):
      newState.isSignInButtonEnabled = isNextButtonEnabled
    }

    return newState
  }
}
