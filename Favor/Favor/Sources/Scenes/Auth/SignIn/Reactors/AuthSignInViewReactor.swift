//
//  AuthSignInViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/01/12.
//

import OSLog
import UIKit

import FavorKit
import FavorNetworkKit
import ReactorKit
import RxCocoa
import RxFlow

public final class AuthSignInViewReactor: Reactor, Stepper {

  // MARK: - Properties
  
  public var initialState: State
  public var steps = PublishRelay<Step>()
  private let networking = UserNetworking()
  private let keychain = KeychainManager()

  // Global States
  let emailValidate = BehaviorRelay<ValidationResult>(value: .empty)
  let passwordValidate = BehaviorRelay<ValidationResult>(value: .empty)
  
  public enum Action {
    case viewNeedsLoaded
    case emailDidUpdate(String)
    case passwordDidUpdate(String)
    case signInButtonDidTap
    case findPasswordButtonDidTap
    // Social Login
    case signedInWithApple(String, String)
  }
  
  public enum Mutation {
    case updateEmail(String)
    case updateEmailValidationResult(ValidationResult)
    case updatePassword(String)
    case updatePasswordValidationResult(ValidationResult)
    case validateSignInButton(Bool)
    case updateLoading(Bool)
  }
  
  public struct State {
    var email: String = ""
    var emailValidationResult: ValidationResult = .empty
    var password: String = ""
    var passwordValidationResult: ValidationResult = .empty
    var isSignInButtonEnabled: Bool = false
    var isLoading: Bool = false
  }
  
  // MARK: - Initializer
  
  init() {
    self.initialState = State()
  }
  
  // MARK: - Functions
  
  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewNeedsLoaded:
      return .empty()

    case .emailDidUpdate(let email):
      let emailVaildate = AuthValidationManager(type: .email).validate(email)
      self.emailValidate.accept(emailVaildate)
      return .concat([
        .just(.updateEmail(email)),
        .just(.updateEmailValidationResult(emailVaildate))
      ])

    case .passwordDidUpdate(let password):
      let passwordValidate = AuthValidationManager(type: .password).validate(password)
      self.passwordValidate.accept(passwordValidate)
      return .concat([
        .just(.updatePassword(password)),
        .just(.updatePasswordValidationResult(passwordValidate))
      ])

    case .signInButtonDidTap:
      let email = self.currentState.email
      let password = self.currentState.password
      return .concat([
        .just(.updateLoading(true)),
        self.requestSignIn(email: email, password: password)
          .flatMap {
            self.steps.accept(AppStep.authIsComplete)
            return Observable<Mutation>.just(.updateLoading(false))
          }
      ])
      
    case .findPasswordButtonDidTap:
      self.steps.accept(AppStep.findPasswordIsRequired)
      return .empty()

    case let .signedInWithApple(email, name):
      print(email, name)
      return .empty()
    }
  }

  public func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
    // Global State의 Validation Result들을 합친 Mutation
    let combineValidationMutation: Observable<Mutation> = .combineLatest(
      self.emailValidate,
      self.passwordValidate,
      resultSelector: { emailValidate, passwordValidate in
        let validates = [emailValidate, passwordValidate]
        return validates.allSatisfy { $0 == .valid } ?
          .validateSignInButton(true) :
          .validateSignInButton(false)
      })
    return .merge(mutation, combineValidationMutation)
  }

  public func reduce(state: State, mutation: Mutation) -> State {
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

    case .updateLoading(let isLoading):
      newState.isLoading = isLoading
    }

    return newState
  }
}

// MARK: - Privates

private extension AuthSignInViewReactor {
  func requestSignIn(email: String, password: String) -> Observable<Void> {
    return Observable<Void>.create { observer in
      let networking = UserNetworking()
      return networking.request(.postSignIn(email: email, password: password))
        .map(ResponseDTO<SignInResponseDTO>.self)
        .flatMap { responseDTO in
          try self.handleSignInSuccess(email: email, password: password, token: responseDTO.data.token)
          return networking.request(.getUser)
        }
        .map(ResponseDTO<UserSingleResponseDTO>.self)
        .map { $0.data }
        .subscribe { userData in
          UserInfoStorage.userNo = userData.userNo
          observer.onNext(())
          observer.onCompleted()
        }
    }
  }

  func handleSignInSuccess(email: String, password: String, token: String) throws {
    guard
      let emailData = email.data(using: .utf8),
      let passwordData = password.data(using: .utf8),
      let tokenData = token.data(using: .utf8)
    else { throw FavorError.optionalBindingFailure([email, password, token]) }

    try self.keychain.set(
      value: emailData,
      account: KeychainManager.Accounts.userEmail.rawValue)
    try self.keychain.set(
      value: passwordData,
      account: KeychainManager.Accounts.userPassword.rawValue)
    try self.keychain.set(
      value: tokenData,
      account: KeychainManager.Accounts.accessToken.rawValue)
    FTUXStorage.authState = .email
  }
}
