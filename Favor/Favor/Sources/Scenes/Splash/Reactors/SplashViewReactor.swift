//
//  SplashViewReactor.swift
//  Favor
//
//  Created by 이창준 on 6/26/23.
//

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
      self.checkAuthState()
      return .empty()
    }
  }
}

// MARK: - Privates

private extension SplashViewReactor {
  func checkAuthState() {
    switch FTUXStorage.authState {
    case .email: // Email 로그인
      // 자동 로그인
      os_log(.debug, "🔐 Signed in via 📨 Email: Navigating to dashboardflow.")
    case .apple: // Apple 로그인
      // 자동 로그인
      // TODO: `fetchAppleCredentialState` 사용해 애플 로그인 상태 확인 후 자동 로그인
      os_log(.debug, "🔐 Signed in via 🍎 Apple: Navigating to dashboardflow flow.")
    case .kakao: // 카카오 로그인
      // 자동 로그인
      os_log(.debug, "🔐 Signed in via 🥥 Kakao: Navigating to dashboardflow flow.")
    case .naver: // 네이버 로그인
      // 자동 로그인
      os_log(.debug, "🔐 Signed in via 🌲 Naver: Navigating to dashboardflow flow.")
    case .undefined:
      os_log(.debug, "🔒 Not signed in to any services: Navigating to auth flow.")
      self.steps.accept(AppStep.authIsRequired)
    }
  }
}
