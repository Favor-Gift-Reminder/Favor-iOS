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
    case passwordDidUpdate(String)
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
      self.emailValidate.accept(emailVaildate)
      return .concat([
        .just(.updatePassword(email)),
        .just(.updateEmailValidationResult(emailVaildate))
      ])

    case .passwordDidUpdate(let password):
      os_log(.debug, "Password TextField did update: \(password)")
      let passwordValidate = AuthValidationManager(type: .password).validate(password)
      self.passwordValidate.accept(passwordValidate)
      return .concat([
        .just(.updatePassword(password)),
        .just(.updatePasswordValidationResult(passwordValidate))
      ])

    case .nextFlowRequested:
      os_log(.debug, "Sign in button did tap.")
      return .empty()

    case .findPasswordButtonDidTap:
      os_log(.debug, "Find password button did tap.")
      self.steps.accept(AppStep.findPasswordIsRequired)
      return .empty()
    }
  }

  func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
    // Global State의 Validation Result들을 합친 Mutation
    let combineValidationMutation: Observable<Mutation> = .combineLatest(
      self.emailValidate,
      self.passwordValidate,
      resultSelector: { emailValidate, passwordValidate in
        if [
          emailValidate,
          passwordValidate
        ].allSatisfy({ $0 == .valid }) {
          os_log(.debug, "Sign-In button became validate.")
          return .validateSignInButton(true)
        } else {
          return .validateSignInButton(false)
        }
      })
    return Observable.of(mutation, combineValidationMutation).merge()
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
