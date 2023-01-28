//
//  SignUpReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/01/16.
//

import OSLog

import ReactorKit
import RxCocoa
import RxFlow

final class SignUpReactor: Reactor, Stepper {
  
  // MARK: - Properties
  
  var initialState: State
  var steps = PublishRelay<Step>()
  
  // Global States
  let emailValidate = BehaviorRelay<ValidateManager.EmailValidate>(value: .empty)
  let passwordValidate = BehaviorRelay<ValidateManager.PasswordValidate>(value: .empty)
  let checkPasswordValidate = BehaviorRelay<ValidateManager.CheckPasswordValidate>(value: .empty)
  
  enum Action {
    case emailTextFieldUpdate(String)
    case passwordTextFieldUpdate(String)
    case checkPasswordTextFieldUpdate(String)
    case nextButtonTap
    case returnKeyboardTap
  }
  
  enum Mutation {
    // Email
    case updateEmail(String)
    case validateEmail(ValidateManager.EmailValidate)
    // Password
    case updatePassword(String)
    case validatePassword(ValidateManager.PasswordValidate)
    // Check Password
    case updateCheckPassword(String)
    case validateCheckPassword(ValidateManager.CheckPasswordValidate)
    // Next Button
    case validateNextButton(Bool)
  }
  
  struct State {
    // Email
    var email: String = ""
    var isEmailValid: ValidateManager.EmailValidate = .empty
    // Password
    var password: String = ""
    var isPasswordValid: ValidateManager.PasswordValidate = .empty
    // Check Password
    var checkPassword: String = ""
    var isPasswordIdentical: ValidateManager.CheckPasswordValidate = .empty
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
    case .emailTextFieldUpdate(let email):
      let emailValidate = ValidateManager.validate(email: email)
      return .concat([
        .just(.updateEmail(email)),
        .just(.validateEmail(emailValidate)),
        self.validate(input: emailValidate)
      ])
      
    case .passwordTextFieldUpdate(let password):
      let passwordValidate = ValidateManager.validate(password: password)
      let isPasswordIdentical = ValidateManager.validate(checkPassword: self.currentState.checkPassword, to: password)
      return .concat([
        .just(.updatePassword(password)),
        .just(.validatePassword(passwordValidate)),
        .just(.validateCheckPassword(isPasswordIdentical)),
        self.validate(input: passwordValidate),
        self.validate(input: isPasswordIdentical)
      ])
      
    case .checkPasswordTextFieldUpdate(let checkPassword):
      let isPasswordIdentical = ValidateManager.validate(checkPassword: checkPassword, to: self.currentState.password)
      return .concat([
        .just(.updateCheckPassword(checkPassword)),
        .just(.validateCheckPassword(isPasswordIdentical)),
        self.validate(input: isPasswordIdentical)
      ])
      
    case .nextButtonTap, .returnKeyboardTap:
//      self.coordinator.showSetProfileFlow()
      return Observable<Mutation>.empty()
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .updateEmail(let email):
      newState.email = email
      
    case .validateEmail(let isEmailValid):
      newState.isEmailValid = isEmailValid
      
    case .updatePassword(let password):
      newState.password = password
      
    case .validatePassword(let isPasswordValid):
      newState.isPasswordValid = isPasswordValid
      
    case .updateCheckPassword(let checkPassword):
      newState.checkPassword = checkPassword
      
    case .validateCheckPassword(let isPasswordIdentical):
      newState.isPasswordIdentical = isPasswordIdentical
      
    case .validateNextButton(let isNextButtonEnabled):
      newState.isNextButtonEnabled = isNextButtonEnabled
    }
    
    return newState
  }
  
}

private extension SignUpReactor {
  
  func validate<T>(input: T) -> Observable<SignUpReactor.Mutation> {
    if T.self == ValidateManager.EmailValidate.self {
      emailValidate.accept(input as! ValidateManager.EmailValidate)
    } else if T.self == ValidateManager.PasswordValidate.self {
      passwordValidate.accept(input as! ValidateManager.PasswordValidate)
    } else {
      checkPasswordValidate.accept(input as! ValidateManager.CheckPasswordValidate)
    }
    
    return Observable.combineLatest(
      emailValidate,
      passwordValidate,
      checkPasswordValidate,
      resultSelector: { emailValidate, passwordValidate, checkPasswordValidate in
        if emailValidate == .valid && passwordValidate == .valid && checkPasswordValidate == .identical {
          return .validateNextButton(true)
        } else {
          return .validateNextButton(false)
        }
      }
    )
  }
  
}
