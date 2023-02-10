//
//  HomeFlow.swift
//  Favor
//
//  Created by 이창준 on 2023/01/29.
//

import UIKit

import RxCocoa
import RxFlow
import RxSwift

final class HomeFlow: Flow {
  
  var root: Presentable { self.rootViewController }
  
  private lazy var rootViewController: UINavigationController = {
    let navigationController = UINavigationController()
    return navigationController
  }()
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? HomeStep else { return .none }
    
    switch step {
    case .homeIsRequired:
      return self.navigateToHome()
    }
  }
  
  private func navigateToHome() -> FlowContributors {
    let homeVC = HomeViewController()
    let homeReactor = HomeReactor()
    homeVC.reactor = homeReactor
    self.rootViewController.pushViewController(homeVC, animated: true)
    return .one(
      flowContributor: .contribute(
        withNextPresentable: homeVC,
        withNextStepper: homeReactor
      )
    )
  }
}
