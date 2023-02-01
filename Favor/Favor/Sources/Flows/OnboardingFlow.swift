//
//  OnboardingFlow.swift
//  Favor
//
//  Created by 김응철 on 2023/02/01.
//

import UIKit

import RxFlow

final class OnboardingFlow: Flow {
  
  var root: Presentable {
    return self.rootViewController
  }
  
  private lazy var rootViewController: UINavigationController = {
    let viewController = UINavigationController()
    return viewController
  }()
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .onboardingIsRequired:
      return self.navigateToOnboarding()
      
    case .onboardingIsComplete:
      return .end(forwardToParentFlowWithStep: AppStep.authIsRequired)
      
    default:
      return .none
    }
  }
}

private extension OnboardingFlow {
  func navigateToOnboarding() -> FlowContributors {
    let viewController = OnboardingViewController()
    self.rootViewController.setViewControllers([viewController], animated: true)
    
    return .one(flowContributor: .contribute(withNext: viewController))
  }
}
