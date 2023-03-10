//
//  AppFlow.swift
//  Favor
//
//  Created by 이창준 on 2023/01/27.
//

import UIKit

import FavorUIKit
import RxCocoa
import RxFlow
import RxSwift

final class AppFlow: Flow {
  
  // MARK: - Properties

  var window: UIWindow // Comment this line.
  var root: Presentable { self.window } // Change to rootViewController

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

    case .dashBoardIsRequired:
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
      return self.navigateToDashboard()
    } else {
      return self.navigateToAuth()
    }
  }

  func navigateToDashboard() -> FlowContributors {
    let dashBoardFlow = TabBarFlow()
    
    return .one(flowContributor: .contribute(
      withNextPresentable: dashBoardFlow,
      withNextStepper: OneStepper(withSingleStep: AppStep.dashBoardIsRequired)
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


