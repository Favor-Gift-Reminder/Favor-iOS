//
//  AppFlow.swift
//  Favor
//
//  Created by 이창준 on 2023/01/27.
//

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
    if FTUXStorage.isSignedIn {
      return self.handleSignedInNavigate()
    } else {
      os_log(.debug, "🏁 Not Signed In: Navigating to auth flow.")
      return self.navigateToAuth()
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
  func handleSignedInNavigate() -> FlowContributors {
    switch FTUXStorage.socialAuthType {
    case .email: // Email 로그인
      return self.navigateToDashboard()
    case .apple: // Apple 로그인
      os_log(.debug, "🏁 Signed in via 🍎 Apple: Navigating to tab bar flow.")
      return self.navigateToDashboard()
    default:
      return .none
    }
  }
}
