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
public final class AppFlow: Flow {

  // MARK: - Properties

  public var root: Presentable { self.rootViewController }
  private let keychain = KeychainManager()

  /// Used only for testFlow.
  private let rootViewController: FavorTabBarController

  // Comment this Initializer.
  public init() {
    self.rootViewController = FavorTabBarController()
  }

  // MARK: - Navigate
  
  public func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .splashIsRequired:
      return self.navigateToSplash()

    case .dashboardIsRequired:
      return self.popToDashboard()

    case .authIsRequired:
      return self.navigateToAuth()

    case .wayBackToRootIsRequired:
      return self.navigateWayBackToRoot()

    default:
      return .none
    }
  }
}

// MARK: - Navigates

private extension AppFlow {
  func navigateToSplash() -> FlowContributors {
    let splashVC = SplashViewController()
    let splashReactor = SplashViewReactor()
    splashVC.reactor = splashReactor

    DispatchQueue.main.async {
      splashVC.modalPresentationStyle = .overFullScreen
      self.rootViewController.present(splashVC, animated: false)
    }

    let splashContributor: [FlowContributor] = [
      .contribute(
        withNextPresentable: splashVC,
        withNextStepper: splashReactor,
        allowStepWhenNotPresented: true
      )
    ]

    return .multiple(flowContributors: splashContributor + self.dashboardContributors())
  }

  func popToDashboard() -> FlowContributors {
    self.rootViewController.dismiss(animated: true)

    return .none
  }

  func navigateToAuth() -> FlowContributors {
    let authFlow = AuthFlow()

    Flows.use(authFlow, when: .created) { root in
      self.rootViewController.dismiss(animated: false) {
        root.modalPresentationStyle = .overFullScreen
        self.rootViewController.present(root, animated: false)
      }
    }

    return .one(flowContributor: .contribute(
      withNextPresentable: authFlow,
      withNextStepper: OneStepper(
        withSingleStep: AppStep.authIsRequired
      )
    ))
  }

  func navigateWayBackToRoot() -> FlowContributors {
    return .one(flowContributor: .forwardToCurrentFlow(withStep: AppStep.authIsRequired))
  }
}

// MARK: - Contributors

private extension AppFlow {
  func dashboardContributors() -> [FlowContributor] {
    let homeFlow = HomeFlow()
    let myPageFlow = MyPageFlow()

    Flows.use(
      homeFlow,
      myPageFlow,
      when: .created
    ) { [unowned self] (homeNC: BaseNavigationController, myPageNC: BaseNavigationController) in
      let navigationControllers: [BaseNavigationController] = [homeNC, myPageNC]
      self.rootViewController.setViewControllers(navigationControllers, animated: false)
    }

    return [
      .contribute(
        withNextPresentable: homeFlow,
        withNextStepper: OneStepper(withSingleStep: AppStep.homeIsRequired)
      ),
      .contribute(
        withNextPresentable: myPageFlow,
        withNextStepper: OneStepper(withSingleStep: AppStep.myPageIsRequired)
      )
    ]
  }
}
