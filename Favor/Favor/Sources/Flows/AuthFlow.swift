//
//  AuthFlow.swift
//  Favor
//
//  Created by 김응철 on 2023/02/01.
//

import UIKit

import RxFlow

final class AuthFlow: Flow {
  
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
    case .authIsRequired:
      return self.navigationToAuth()
      
    case .authIsComplete:
      return .end(forwardToParentFlowWithStep: AppStep.authIsComplete)
      
    case .signInIsRequired:
      return self.NavigationToSignIn()
      
    case .signUpIsRequired:
      return self.NavigationToSignUp()
      
    case .setProfileIsRequired:
      return self.NavigationToSetProfile()
      
    case .termIsRequired:
      return self.NavigationToTerm()
      
    case .onboardingIsRequired:
      return .none
      
    case .onboardingIsComplete:
      return .none
      
    default:
      return .none
    }
  }
}

private extension AuthFlow {
  func navigationToAuth() -> FlowContributors {
    let viewController = SelectSignInViewController()
    let reactor = SelectSignInViewReactor()
    viewController.reactor = reactor
    self.rootViewController.setViewControllers([viewController], animated: true)
    
    return .one(flowContributor: .contribute(
      withNextPresentable: viewController,
      withNextStepper: reactor
    ))
  }
  
  func navigationToOnboarding() -> FlowContributors {
    let onboardingFlow = OnboardingFlow()

    Flows.use(onboardingFlow, when: .created) { [unowned self] root in
      DispatchQueue.main.async {
        root.modalPresentationStyle = .overFullScreen
        self.rootViewController.present(root, animated: true)
      }
    }

    return .one(flowContributor: .contribute(
      withNextPresentable: onboardingFlow,
      withNextStepper: OneStepper(withSingleStep: AppStep.onboardingIsRequired)
    ))
  }
  
  func NavigationToSignIn() -> FlowContributors {
    let viewController = SignInViewController()
    let reactor = SignInViewReactor()
    viewController.reactor = reactor
    self.rootViewController.pushViewController(viewController, animated: true)
    
    return .none
  }
  
  func NavigationToSignUp() -> FlowContributors {
    let viewController = SignUpViewController()
    let reactor = SignUpViewReactor()
    viewController.reactor = reactor
    self.rootViewController.pushViewController(viewController, animated: true)
    
    return .none
  }
  
  func NavigationToSetProfile() -> FlowContributors {
    let viewController = SetProfileViewController()
    let reactor = SetProfileViewReactor(pickerManager: PHPickerManager())
    viewController.reactor = reactor
    self.rootViewController.pushViewController(viewController, animated: true)
    
    return .none
  }
  
  func NavigationToTerm() -> FlowContributors {
    let viewController = TermViewController()
    self.rootViewController.pushViewController(viewController, animated: true)
    
    return .none
  }
}
