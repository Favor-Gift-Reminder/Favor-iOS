//
//  SignUpReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/01/16.
//

import OSLog

import ReactorKit

final class SignUpReactor: Reactor {
  
  // MARK: - Properties
  
  weak var coordinator: AuthCoordinator?
  var initialState: State
  
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
    case validateCheckPassword(Bool)
  }
  
  struct State {
    // Email
    var email: String = ""
    var isEmailValid: ValidateManager.EmailValidate?
    // Password
    var password: String = ""
    var isPasswordValid: ValidateManager.PasswordValidate?
    // Check Password
    var checkPassword: String = ""
    var isPasswordIdentical: Bool?
    // Button
    var isNextButtonEnabled: Bool = false
  }
  
  // MARK: - Initializer
  
  init(coordinator: AuthCoordinator) {
    self.coordinator = coordinator
    self.initialState = State()
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .emailTextFieldUpdate(let email):
      let emailValidate = ValidateManager.validate(email: email)
      return .concat([
        .just(.updateEmail(email)),
        .just(.validateEmail(emailValidate))
      ])
      
    case .passwordTextFieldUpdate(let password):
      let passwordValidate = ValidateManager.validate(password: password)
      return .concat([
        .just(.updatePassword(password)),
        .just(.validatePassword(passwordValidate))
      ])
      
    case .checkPasswordTextFieldUpdate(let checkPassword):
      let isPasswordIdentical: Bool = (self.currentState.password == checkPassword) ? true: false
      return .concat([
        .just(.updateCheckPassword(checkPassword)),
        .just(.validateCheckPassword(isPasswordIdentical))
      ])
      
    case .nextButtonTap:
      os_log(.info, "Next button tap.")
      return Observable<Mutation>.empty()
      
    case .returnKeyboardTap:
      os_log(.info, "Keyboard return tap.")
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
    }
    
    return newState
  }
  
}
