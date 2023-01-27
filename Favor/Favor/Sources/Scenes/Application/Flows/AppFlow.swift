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
    return .none
  }
}

private extension AppFlow {
  
  func navigateToAuth() -> FlowContributors {
    let authFlow = AuthFlow()
    
    Flows.use(authFlow, when: .created) { [unowned self] root in
      self.rootViewController.pushViewController(root, animated: false)
    }
    
    return .none
  }
}
