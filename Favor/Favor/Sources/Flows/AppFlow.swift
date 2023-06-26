//
//  AppFlow.swift
//  Favor
//
//  Created by 이창준 on 2023/01/27.
//

import AuthenticationServices
import OSLog
import UIKit

import FavorKit
import RxCocoa
import RxFlow
import RxSwift

@MainActor
final class AppFlow: Flow {
  
  // MARK: - Properties

  var window: UIWindow // Comment this line.
  var root: Presentable { self.window } // Change to rootViewController
  private let keychain = KeychainManager()

  /// Used only for testFlow.
  private lazy var rootViewController: BaseNavigationController = {
    let viewController = BaseNavigationController()
    viewController.setNavigationBarHidden(true, animated: false)
    return viewController
  }()

  // Comment this Initializer.
  init(window: UIWindow) {
    self.window = window
  }

  // MARK: - Navigate
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .rootIsRequired:
      return self.navigateToRoot()

    case .authIsRequired:
      return self.navigateToAuth()

    case .tabBarIsRequired:
      return self.navigateToDashboard()

    case .testIsRequired:
      return self.navigateToTest()
      
    default:
      return .none
    }
  }
}

private extension AppFlow {
  func navigateToRoot() -> FlowContributors {
    switch FTUXStorage.authState {
    case .email: // Email 로그인
                 // TODO: 자동 로그인
      return self.navigateToDashboard()
    case .apple: // Apple 로그인
      os_log(.debug, "🔐 Signed in via 🍎 Apple: Navigating to tab bar flow.")
      // TODO: `fetchAppleCredentialState` 사용해 애플 로그인 상태 확인 후 자동 로그인
      return self.navigateToDashboard()
    case .kakao: // 카카오 로그인
      os_log(.debug, "🔐 Signed in via 🥥 Kakao: Navigating to tab bar flow.")
      return .none
    case .naver: // 네이버 로그인
      os_log(.debug, "🔐 Signed in via 🌲 Naver: Navigating to tab bar flow.")
      return .none
    case .undefined:
      os_log(.debug, "🔒 Not signed in to any services: Navigating to auth flow.")
      return .none
    }
  }

  func navigateToDashboard() -> FlowContributors {
    let dashboardFlow = DashboardFlow()

    Flows.use(dashboardFlow, when: .created) { [unowned self] root in
      DispatchQueue.main.async {
        self.window.rootViewController = root
      }
    }

    return .one(flowContributor: .contribute(
      withNextPresentable: dashboardFlow,
      withNextStepper: OneStepper(
        withSingleStep: AppStep.tabBarIsRequired
      )
    ))
  }
  
  func navigateToAuth() -> FlowContributors {
    let authFlow = AuthFlow()
    
    Flows.use(authFlow, when: .created) { [unowned self] root in
      DispatchQueue.main.async {
        self.window.rootViewController = root
      }
    }
    
    return .one(flowContributor: .contribute(
      withNextPresentable: authFlow,
      withNextStepper: OneStepper(
        withSingleStep: AppStep.authIsRequired
      )
    ))
  }
  
  /// UI Test를 위한 navigate 메서드
  func navigateToTest() -> FlowContributors {
    let testFlow = AppFlow(window: self.window) // Change to Test Flow here.
    
    Flows.use(testFlow, when: .created) { [unowned self] root in
      DispatchQueue.main.async {
        self.window.rootViewController = root // Change to commented lines.
//        root.modalPresentationStyle = .overFullScreen
//        self.rootViewController.present(root, animated: false)
      }
    }
    
    return .one(flowContributor: .contribute(
      withNextPresentable: testFlow,
      withNextStepper: OneStepper(withSingleStep: AppStep.rootIsRequired) // Change to Test Step here.
    ))
  }
}

// MARK: - Privates

private extension AppFlow {
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
