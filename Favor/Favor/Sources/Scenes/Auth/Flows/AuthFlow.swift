//
//  AuthFlow.swift
//  Favor
//
//  Created by 이창준 on 2023/01/27.
//

import UIKit

import RxCocoa
import RxFlow
import RxSwift

final class AuthFlow: Flow {
  
  var root: Presentable { self.rootViewController }
  
  private lazy var rootViewController: UINavigationController = {
    let navigationController = UINavigationController()
    return navigationController
  }()
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AuthStep else { return .none }
    
    switch step {
    case .selectSignInIsRequired:
      return self.navigateToSelectSignIn()
      
    case .signInIsRequired:
      return .none
      
    case .signUpIsRequired:
      return .none
    }
  }
  
}

private extension AuthFlow {
  
  func navigateToSelectSignIn() -> FlowContributors {
    let selectSignInReactor = SelectSignInReactor()
    let selectSignInVC = SelectSignInViewController()
    selectSignInVC.reactor = selectSignInReactor
    self.rootViewController.pushViewController(selectSignInVC, animated: true)
    return .one(
      flowContributor: .contribute(
        withNextPresentable: selectSignInVC,
        withNextStepper: selectSignInReactor
      )
    )
  }
  
}
