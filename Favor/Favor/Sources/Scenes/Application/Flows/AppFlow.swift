//
//  AppFlow.swift
//  Favor
//
//  Created by 이창준 on 2023/01/27.
//

import UIKit

import RxFlow

final class AppFlow: Flow {
  
  // MARK: - Properties
  
  var root: Presentable { self.rootViewController }
  
  private lazy var rootViewController: UINavigationController = {
    let navigationController = UINavigationController()
    return navigationController
  }()
  
  // MARK: - Initializer
  
  init() { }
  
  // MARK: - Navigate
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .onboardingIsRequired:
      return .none
    case .authIsRequired:
      return .none
    case .mainIsRequired:
      return .none
    }
  }
}

private extension AppFlow {
  
  func navigateToOnboarding() -> FlowContributors {
    let onboardFlow = AuthFlow()
    
    Flows.use(onboardFlow, when: .created) { [unowned self] root in
      self.rootViewController.pushViewController(root, animated: false)
    }
    
    return .one(
      flowContributor: .contribute(
        withNextPresentable: onboardFlow,
        withNextStepper: OneStepper(withSingleStep: AppStep.onboardingIsRequired)
      )
    )
  }
  
  func navigateToAuth() -> FlowContributors {
    let authFlow = AuthFlow()
    
    Flows.use(authFlow, when: .created) { [unowned self] root in
      self.rootViewController.pushViewController(root, animated: false)
    }
    
    return .one(
      flowContributor: .contribute(
        withNextPresentable: authFlow,
        withNextStepper: OneStepper(withSingleStep: AppStep.authIsRequired)
      )
    )
  }
  
  func navigateToMain() -> FlowContributors {
    let mainFlow = AuthFlow()
    
    Flows.use(mainFlow, when: .created) { [unowned self] root in
      self.rootViewController.pushViewController(root, animated: false)
    }
    
    return .one(
      flowContributor: .contribute(
        withNextPresentable: mainFlow,
        withNextStepper: OneStepper(withSingleStep: AppStep.mainIsRequired)
      )
    )
  }
  
}
