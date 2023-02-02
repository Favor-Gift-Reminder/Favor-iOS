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
      return self.navigateToAuth()
      
    case .authIsComplete:
      return .end(forwardToParentFlowWithStep: AppStep.authIsComplete)
      
    case .signInIsRequired:
      return self.pushToSignInVC()
      
    case .signUpIsRequired:
      return self.pushToSignUpVC()
      
    case .setProfileIsRequired:
      return self.pushToSetProfileVC()
      
    case .termIsRequired:
      return self.pushToTermVC()
      
    default:
      return .none
    }
  }
}

private extension AuthFlow {
  func navigateToAuth() -> FlowContributors {
    let viewController = SelectSignInViewController()
    let reactor = SelectSignInReactor()
    viewController.reactor = reactor
    
    return .one(flowContributor: .contribute(
      withNextPresentable: viewController,
      withNextStepper: reactor
    ))
  }
  
  func pushToSignInVC() -> FlowContributors {
    let viewController = SignInViewController()
    let reactor = SignInReactor()
    viewController.reactor = reactor
    self.rootViewController.pushViewController(viewController, animated: true)
    
    return .none
  }
  
  func pushToSignUpVC() -> FlowContributors {
    let viewController = SignUpViewController()
    let reactor = SignUpReactor()
    viewController.reactor = reactor
    self.rootViewController.pushViewController(viewController, animated: true)
    
    return .none
  }
  
  func pushToSetProfileVC() -> FlowContributors {
    let viewController = SetProfileViewController()
    let reactor = SetProfileReactor(pickerManager: PHPickerManager())
    viewController.reactor = reactor
    self.rootViewController.pushViewController(viewController, animated: true)
    
    return .none
  }
  
  func pushToTermVC() -> FlowContributors {
    let viewController = TermViewController()
    self.rootViewController.pushViewController(viewController, animated: true)
    
    return .none
  }
}
