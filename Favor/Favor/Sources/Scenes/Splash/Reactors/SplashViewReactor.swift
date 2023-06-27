//
//  SplashViewReactor.swift
//  Favor
//
//  Created by 이창준 on 6/26/23.
//

import AuthenticationServices
import OSLog

import FavorKit
import FavorNetworkKit
import ReactorKit
import RxCocoa
import RxFlow

public final class SplashViewReactor: Reactor, Stepper {

  // MARK: - Properties

  public var initialState: State
  public let steps = PublishRelay<Step>()
  private let keychain = KeychainManager()

  public enum Action {
    case viewNeedsLoaded
  }

  public enum Mutation {

  }

  public struct State {

  }

  // MARK: - Initializer

  init() {
    self.initialState = State()
  }

  // MARK: - Functions

  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewNeedsLoaded:
      return self.checkAuthState()
    }
  }
}

// MARK: - Privates

private extension SplashViewReactor {
  func checkAuthState() -> Observable<Mutation> {
    switch FTUXStorage.authState {
    case .email: // Email 로그인
      // 자동 로그인
      return self.requestSignIn()
        .asObservable()
        .flatMap { token -> Observable<Mutation> in
          os_log(.debug, "🔐 Signed in via 📨 Email: Navigating to dashboardflow.")
          print(token)
          // Token 저장
          self.steps.accept(AppStep.dashboardIsRequired)
          return .empty()
        }
    case .apple: // Apple 로그인
      // 자동 로그인
      // TODO: `fetchAppleCredentialState` 사용해 애플 로그인 상태 확인 후 자동 로그인
      os_log(.debug, "🔐 Signed in via 🍎 Apple: Navigating to dashboardflow flow.")
      return .empty()
    case .kakao: // 카카오 로그인
      // 자동 로그인
      os_log(.debug, "🔐 Signed in via 🥥 Kakao: Navigating to dashboardflow flow.")
      return .empty()
    case .naver: // 네이버 로그인
      // 자동 로그인
      os_log(.debug, "🔐 Signed in via 🌲 Naver: Navigating to dashboardflow flow.")
      return .empty()
    case .undefined:
      os_log(.debug, "🔒 Not signed in to any services: Navigating to auth flow.")
      self.steps.accept(AppStep.authIsRequired)
      return .empty()
    }
  }

  func requestSignIn() -> Single<String> {
    return Single<String>.create { single in
      let networking = UserNetworking()
      guard
        let emailData = try? self.keychain.get(account: KeychainManager.Accounts.userEmail.rawValue),
        let passwordData = try? self.keychain.get(account: KeychainManager.Accounts.userPassword.rawValue)
      else { return Disposables.create() }
      let email = String(decoding: emailData, as: UTF8.self)
      let password = String(decoding: passwordData, as: UTF8.self)

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

  func fetchAppleCredentialState() {
    let appleIDProvider = ASAuthorizationAppleIDProvider()
    guard let userID = try? self.keychain.get(account: KeychainManager.Accounts.userID.rawValue) else { return }
    let decodedUserID = String(decoding: userID, as: UTF8.self)
    appleIDProvider.getCredentialState(forUserID: decodedUserID) { state, _ in
      switch state {
      case .authorized:
        print("Authorized")
      case .notFound, .revoked:
        print("Need re-auth")
      case .transferred:
        break
      @unknown default:
        fatalError()
      }
    }
  }
}
