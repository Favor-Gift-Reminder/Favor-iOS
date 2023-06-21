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
  let networking = UserNetworking()

  // Global States
  let emailValidate = BehaviorRelay<ValidationResult>(value: .empty)
  let passwordValidate = BehaviorRelay<ValidationResult>(value: .empty)
  
  public enum Action {
    case viewNeedsLoaded
    case emailDidUpdate(String)
    case passwordDidUpdate(String)
    case signInButtonDidTap
    case socialSignInButtonDidTap(AuthMethod)
    case findPasswordButtonDidTap
  }
  
  public enum Mutation {
    case updateEmail(String)
    case updateEmailValidationResult(ValidationResult)
    case updatePassword(String)
    case updatePasswordValidationResult(ValidationResult)
    case validateSignInButton(Bool)
    case pulseSocialAuth(AuthMethod)
  }
  
  public struct State {
    var email: String = ""
    var emailValidationResult: ValidationResult = .empty
    var password: String = ""
    var passwordValidationResult: ValidationResult = .empty
    var isSignInButtonEnabled: Bool = false
    @Pulse var requestedSocialAuth: AuthMethod = .undefined
  }
  
  // MARK: - Initializer
  
  init() {
    self.initialState = State()
  }
  
  // MARK: - Functions
  
  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewNeedsLoaded:
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

    case .signInButtonDidTap:
      // Login
      return .empty()

    case .socialSignInButtonDidTap(let socialAuth):
      os_log(.debug, "Sign-In with social did tap: \(String(describing: socialAuth))")
      return .just(.pulseSocialAuth(socialAuth))

    case .findPasswordButtonDidTap:
      self.steps.accept(AppStep.findPasswordIsRequired)
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

    case .pulseSocialAuth(let socialAuth):
      newState.requestedSocialAuth = socialAuth
    }

    return newState
  }
}
