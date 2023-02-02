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
  
  var window: UIWindow
  var root: Presentable { self.window }
  
  // MARK: - Initializer
  
  init(with window: UIWindow) {
    self.window = window
  }
  
  // MARK: - Navigate
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .onboardingIsRequired:
      let onboardingFlow = OnboardingFlow()
      
      Flows.use(onboardingFlow, when: .created) { root in
        self.window.rootViewController = root
      }
      
      return .one(flowContributor: .contribute(
        withNextPresentable: onboardingFlow,
        withNextStepper: OneStepper(withSingleStep: AppStep.onboardingIsRequired)
      ))
      
    case .authIsRequired:
      let authFlow = AuthFlow()
      
      Flows.use(authFlow, when: .created) { root in
        self.window.rootViewController = root
      }
      
      return .one(flowContributor: .contribute(
        withNextPresentable: authFlow,
        withNextStepper: OneStepper(withSingleStep: AppStep.authIsRequired)
      ))
      
    case .mainIsRequired:
      // TODO: 멀티 플로우 정의하기
      return .none
      
    default:
      return .none
    }
  }
}
