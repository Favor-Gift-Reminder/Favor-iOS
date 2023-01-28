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
  
  var rootWindow: UIWindow
  var root: Presentable { self.rootWindow }
  
  // MARK: - Initializer
  
  init(with window: UIWindow) {
    self.rootWindow = window
  }
  
  // MARK: - Navigate
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .onboardingIsRequired:
      return self.navigateToOnboarding()
      
    case .authIsRequired:
      return self.navigateToAuth()
      
    case .mainIsRequired:
      return self.navigateToMain()
    }
  }
}

private extension AppFlow {
  
  func navigateToOnboarding() -> FlowContributors {
    let onboardFlow = AuthFlow() // Onboard
    
    // Onboard
    
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
      self.rootWindow.rootViewController = root
    }
    
    return .one(
      flowContributor: .contribute(
        withNextPresentable: authFlow,
        withNextStepper: OneStepper(withSingleStep: AuthStep.selectSignInIsRequired)
      )
    )
  }
  
  func navigateToMain() -> FlowContributors {
    let mainFlow = AuthFlow()
    
    Flows.use(mainFlow, when: .created) { [unowned self] root in
      self.rootWindow.rootViewController = root
    }
    
    return .one(
      flowContributor: .contribute(
        withNextPresentable: mainFlow,
        withNextStepper: OneStepper(withSingleStep: AppStep.mainIsRequired)
      )
    )
  }
  
}
