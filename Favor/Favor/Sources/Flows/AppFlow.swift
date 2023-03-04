//
//  AppFlow.swift
//  Favor
//
//  Created by 이창준 on 2023/01/27.
//

import UIKit

import RxCocoa
import RxFlow
import RxSwift

final class AppFlow: Flow {
  
  // MARK: - Properties
  
  var root: Presentable { self.rootViewController }
  
  private lazy var rootViewController: UINavigationController = {
    let viewController = UINavigationController()
    viewController.setNavigationBarHidden(true, animated: false)
    return viewController
  }()

  // MARK: - Navigate
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .authIsRequired:
      return self.navigationToAuthScreen()
    case .dashBoardIsRequired:
      return self.navigationToDashBoardScreen()
    case .testIsRequired:
      return self.navigateToTest()
    default:
      return .none
    }
  }
}

private extension AppFlow {
  func navigationToDashBoardScreen() -> FlowContributors {
    let dashBoardFlow = TabBarFlow()
    
    return .one(flowContributor: .contribute(
      withNextPresentable: dashBoardFlow,
      withNextStepper: OneStepper(withSingleStep: AppStep.dashBoardIsRequired)
    ))
  }
  
  func navigationToAuthScreen() -> FlowContributors {
    let authFlow = AuthFlow()
    
    Flows.use(authFlow, when: .created) { [unowned self] root in
      DispatchQueue.main.async {
        root.modalPresentationStyle = .overFullScreen
        self.rootViewController.present(root, animated: false)
      }
    }
    
    return .one(flowContributor: .contribute(
      withNextPresentable: authFlow,
      withNextStepper: OneStepper(withSingleStep: AppStep.authIsRequired)
    ))
  }
  
  func navigateToDashBoard() -> FlowContributors {
    return .none
  }
  
  /// UI Test를 위한 navigate 메서드
  func navigateToTest() -> FlowContributors {
    let testFlow = AuthFlow() // Change to Test Flow here.
    
    Flows.use(testFlow, when: .created) { [unowned self] root in
      DispatchQueue.main.async {
        root.modalPresentationStyle = .overFullScreen
        self.rootViewController.present(root, animated: false)
      }
    }
    
    return .one(flowContributor: .contribute(
      withNextPresentable: testFlow,
      withNextStepper: OneStepper(withSingleStep: AppStep.authIsRequired) // Change to Test Step here.
    ))
  }
}
