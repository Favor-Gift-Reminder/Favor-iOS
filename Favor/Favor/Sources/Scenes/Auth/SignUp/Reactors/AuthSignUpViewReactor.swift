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
      if self.currentState.isNextButtonEnabled {
        let email = self.currentState.email
        let password = self.currentState.password

        return .concat([
          .just(.updateLoading(true)),
          self.requestSignUp(email: email, password: password)
            .asObservable()
            .flatMap { user -> Observable<Mutation> in
              return .concat([
                // Local User update
                self.updateUser(with: user)
                  .asObservable()
                  .flatMap { user -> Observable<Mutation> in
                    self.steps.accept(AppStep.setProfileIsRequired(user))
                    return .empty()
                  }
                  .catch { _ in
                    return .just(.updateLoading(false))
                  },
                // Request sign-in to retrieve access token
                self.requestSignIn(email: email, password: password)
                  .asObservable()
                  .flatMap { token -> Observable<Mutation> in
                    do {
                      guard
                        let emailData = email.data(using: .utf8),
                        let passwordData = password.data(using: .utf8),
                        let tokenData = token.data(using: .utf8)
                      else { return .empty() }
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
                    } catch {
                      os_log(.error, "\(error)")
                      return .just(.updateLoading(false))
                    }
                    return .just(.updateLoading(false))
                  }
                ])
            }
            .catch { error in
              if let error = error as? APIError {
                os_log(.error, "\(error.description)")
              }
              return .just(.updateLoading(false))
            }
        ])
      }
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

// MARK: - Privates

private extension AuthSignUpViewReactor {
  func requestSignUp(email: String, password: String) -> Single<User> {
    return Single<User>.create { single in
      let networking = UserNetworking()
      let disposable = networking.request(.postSignUp(email: email, password: password))
        .take(1)
        .asSingle()
        .subscribe(onSuccess: { response in
          do {
            let responseDTO: ResponseDTO<UserResponseDTO> = try APIManager.decode(response.data)
            single(.success(User(dto: responseDTO.data)))
          } catch {
            single(.failure(error))
          }
        }, onFailure: { error in
          if let error = error as? APIError {
            os_log(.error, "\(error.description)")
          }
          single(.failure(error))
        })

      return Disposables.create {
        disposable.dispose()
      }
    }
  }

  func updateUser(with user: User) -> Single<User> {
    return Single<User>.create { single in
      let task = _Concurrency.Task {
        do {
          try await self.workbench.write { transaction in
            transaction.update(user.realmObject(), update: .all)
          }
          single(.success(user))
        } catch {
          single(.failure(error))
        }
      }

      return Disposables.create {
        task.cancel()
      }
    }
  }

  func requestSignIn(email: String, password: String) -> Single<String> {
    return Single<String>.create { single in
      let networking = UserNetworking()
      let disposable = networking.request(.postSignIn(email: email, password: password))
        .take(1)
        .asSingle()
        .subscribe(onSuccess: { response in
          do {
            let responseDTO: ResponseDTO<SignInResponseDTO> = try APIManager.decode(response.data)
            single(.success(responseDTO.data.token))
          } catch {
            single(.failure(error))
          }
        }, onFailure: { error in
          single(.failure(error))
        })

      return Disposables.create {
        disposable.dispose()
      }
    }
  }
}
