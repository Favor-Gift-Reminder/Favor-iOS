//
//  SignUpViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/01/16.
//

import OSLog

import ReactorKit
import RxCocoa
import RxFlow

final class SignUpViewReactor: Reactor, Stepper {
  
  // MARK: - Properties
  
  var initialState: State
  var steps = PublishRelay<Step>()
  
  // Global States
  let emailValidate = BehaviorRelay<ValidationResult>(value: .empty)
  let passwordValidate = BehaviorRelay<ValidationResult>(value: .empty)
  let confirmPasswordValidate = BehaviorRelay<ValidationResult>(value: .empty)
  
  enum Action {
    case emailTextFieldDidUpdate(String)
    case passwordTextFieldDidUpdate(String)
    case confirmPasswordTextFieldDidUpdate(String)
    case nextFlowRequested
  }
  
  enum Mutation {
    // Email
    case updateEmail(String)
    case updateEmailValidationResult(ValidationResult)
    // Password
    case updatePassword(String)
    case updatePasswordValidationResult(ValidationResult)
    // Check Password
    case updateConfirmPassword(String)
    case updateConfirmPasswordValidationResult(ValidationResult)
    // Next Button
    case validateNextButton(Bool)
    case acceptNewFlow
  }
  
  struct State {
    // Email
    var email: String = ""
    var emailValidationResult: ValidationResult = .empty
    // Password
    var password: String = ""
    var passwordValidationResult: ValidationResult = .empty
    // Check Password
    var confirmPassword: String = ""
    var confirmPasswordValidationResult: ValidationResult = .empty
    // Button
    var isNextButtonEnabled: Bool = false
  }
  
  // MARK: - Initializer
  
  init() {
    self.initialState = State()
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .emailTextFieldDidUpdate(let email):
      os_log(.debug, "Email TextField did update: \(email)")
      let emailValidationResult = AuthValidationManager(type: .email).validate(email)
      self.emailValidate.accept(emailValidationResult)
      return .concat([
        .just(.updateEmail(email)),
        .just(.updateEmailValidationResult(emailValidationResult))
      ])
      
    case .passwordTextFieldDidUpdate(let password):
      os_log(.debug, "Password TextField did update: \( password)")
      let passwordValidationResult = AuthValidationManager(type: .password).validate(password)
      self.passwordValidate.accept(passwordValidationResult)
      let confirmPasswordValidationResult = AuthValidationManager(type: .confirmPassword).confirm(
        password,
        with: self.currentState.confirmPassword
      )
      return .concat([
        .just(.updatePassword(password)),
        .just(.updatePasswordValidationResult(passwordValidationResult)),
        .just(.updateConfirmPasswordValidationResult(confirmPasswordValidationResult))
      ])
      
    case .confirmPasswordTextFieldDidUpdate(let confirmPassword):
      os_log(.debug, "Confirm Password TextField did update: \(confirmPassword)")
      let confirmPasswordValidationResult = AuthValidationManager(type: .confirmPassword).confirm(
        confirmPassword,
        with: self.currentState.password
      )
      self.confirmPasswordValidate.accept(confirmPasswordValidationResult)
      return .concat([
        .just(.updateConfirmPassword(confirmPassword)),
        .just(.updateConfirmPasswordValidationResult(confirmPasswordValidationResult))
      ])
      
    case .nextFlowRequested:
      os_log(.debug, "Next button or return key from keyboard did tap.")
      return self.currentState.isNextButtonEnabled ? .just(.acceptNewFlow) : .empty()
    }
  }

  func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
    let combineValidationsMutation: Observable<Mutation> = Observable.combineLatest(
      self.emailValidate,
      self.passwordValidate,
      self.confirmPasswordValidate,
      resultSelector: { emailValidate, passwordValidate, confirmPasswordValidate in
        if emailValidate == .valid && passwordValidate == .valid && confirmPasswordValidate == .valid {
          return .validateNextButton(true)
        } else {
          return .validateNextButton(false)
        }
      })
    return .concat([
      Observable.of(mutation, combineValidationsMutation).merge()
    ])
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .updateEmail(let email):
      newState.email = email
      
    case .updateEmailValidationResult(let isEmailValid):
      newState.emailValidationResult = isEmailValid
      
    case .updatePassword(let password):
      newState.password = password
      
    case .updatePasswordValidationResult(let isPasswordValid):
      newState.passwordValidationResult = isPasswordValid
      
    case .updateConfirmPassword(let checkPassword):
      newState.confirmPassword = checkPassword
      
    case .updateConfirmPasswordValidationResult(let isPasswordIdentical):
      newState.confirmPasswordValidationResult = isPasswordIdentical
      
    case .validateNextButton(let isNextButtonEnabled):
      newState.isNextButtonEnabled = isNextButtonEnabled

    case .acceptNewFlow:
      self.steps.accept(AppStep.authIsComplete)
    }
    
    return newState
  }
}
