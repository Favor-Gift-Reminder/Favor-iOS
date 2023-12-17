//
//  AuthSignUpViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/01/16.
//

import OSLog

import FavorKit
import FavorNetworkKit
import Moya
import ReactorKit
import RxCocoa
import RxFlow

public final class AuthSignUpViewReactor: Reactor, Stepper {

  // MARK: - Properties
  
  public var initialState: State
  public var steps = PublishRelay<Step>()
  private let workbench = RealmWorkbench()
  private let keychain = KeychainManager()

  // Global States
  let emailValidate = BehaviorRelay<ValidationResult>(value: .empty)
  let passwordValidate = BehaviorRelay<ValidationResult>(value: .empty)
  let confirmPasswordValidate = BehaviorRelay<ValidationResult>(value: .empty)
  
  public enum Action {
    case emailTextFieldDidUpdate(String)
    case passwordTextFieldDidUpdate(String)
    case confirmPasswordTextFieldDidUpdate(String)
    case nextButtonDidTap
  }
  
  public enum Mutation {
    case presentNewToast(ToastMessage)
    // Email
    case updateEmail(String)
    case updateEmailValidationResult(ValidationResult)
    // Password
    case updatePassword(String)
    case updatePasswordValidationResult(ValidationResult)
    // Check Password
    case updateConfirmPassword(String)
    case updateConfirmPasswordValidationResult(ValidationResult)
    // UI
    case validateNextButton(Bool)
    case updateLoading(Bool)
  }
  
  public struct State {
    @Pulse var toastMessage: ToastMessage?
    // Email
    var email: String = ""
    var emailValidationResult: ValidationResult = .empty
    // Password
    var password: String = ""
    var passwordValidationResult: ValidationResult = .empty
    // Check Password
    var confirmPassword: String = ""
    var confirmPasswordValidationResult: ValidationResult = .empty
    // UI
    var isNextButtonEnabled: Bool = false
    var isLoading: Bool = false
  }
  
  // MARK: - Initializer
  
  init() {
    self.initialState = State()
  }
  
  // MARK: - Functions
  
  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .emailTextFieldDidUpdate(let email):
      let emailValidationResult = AuthValidationManager(type: .email).validate(email)
      self.emailValidate.accept(emailValidationResult)
      return .concat([
        .just(.updateEmail(email)),
        .just(.updateEmailValidationResult(emailValidationResult))
      ])
      
    case .passwordTextFieldDidUpdate(let password):
      let passwordValidationResult = AuthValidationManager(type: .password).validate(password)
      self.passwordValidate.accept(passwordValidationResult)
      let confirmPasswordValidationResult = AuthValidationManager(type: .confirmPassword).confirm(
        password,
        with: self.currentState.confirmPassword
      )
      self.confirmPasswordValidate.accept(confirmPasswordValidationResult)
      return .concat([
        .just(.updatePassword(password)),
        .just(.updatePasswordValidationResult(passwordValidationResult)),
        .just(.updateConfirmPasswordValidationResult(confirmPasswordValidationResult))
      ])
      
    case .confirmPasswordTextFieldDidUpdate(let confirmPassword):
      let confirmPasswordValidationResult = AuthValidationManager(type: .confirmPassword).confirm(
        confirmPassword,
        with: self.currentState.password
      )
      self.confirmPasswordValidate.accept(confirmPasswordValidationResult)
      return .concat([
        .just(.updateConfirmPassword(confirmPassword)),
        .just(.updateConfirmPasswordValidationResult(confirmPasswordValidationResult))
      ])
      
    case .nextButtonDidTap:
      let email = self.currentState.email
      let password = self.currentState.password
      let tempStorage = AuthTempStorage.shared
      tempStorage.saveEmail(email)
      tempStorage.savePassword(password)
      self.steps.accept(AppStep.setProfileIsRequired(.init()))
      return .empty()
    }
  }

  public func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
    let combineValidationsMutation: Observable<Mutation> = .combineLatest(
      self.emailValidate,
      self.passwordValidate,
      self.confirmPasswordValidate,
      resultSelector: { emailValidate, passwordValidate, confirmPasswordValidate in
        if [
          emailValidate,
          passwordValidate,
          confirmPasswordValidate
        ].allSatisfy({ $0 == .valid }) {
          return .validateNextButton(true)
        } else {
          return .validateNextButton(false)
        }
      })
    return Observable.of(mutation, combineValidationsMutation).merge()
  }
  
  public func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .presentNewToast(let message):
      newState.toastMessage = message

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
      
    case .updateLoading(let isLoading):
      newState.isLoading = isLoading
    }
    
    return newState
  }
}
