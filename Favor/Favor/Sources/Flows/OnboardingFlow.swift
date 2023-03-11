//
//  OnboardingFlow.swift
//  Favor
//
//  Created by 김응철 on 2023/02/01.
//

import UIKit

import FavorKit
import RxFlow

final class OnboardingFlow: Flow {
  
  var root: Presentable {
    return self.rootViewController
  }
  
  let rootViewController = OnboardingViewController()
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .onboardingIsRequired:
      return .one(flowContributor: .contribute(withNext: self.rootViewController))

    case .onboardingIsComplete:
      FTUXStorage.isFirstLaunch = false
      return .end(forwardToParentFlowWithStep: AppStep.onboardingIsComplete)
      
    default:
      return .none
    }
  }
}
