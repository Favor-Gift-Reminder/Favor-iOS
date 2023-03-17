//
//  HomeFlow.swift
//  Favor
//
//  Created by 이창준 on 2023/03/11.
//

import UIKit

import FavorKit
import RxFlow

final class HomeFlow: Flow {

  var root: Presentable { self.rootViewController }

  let rootViewController = BaseNavigationController()

  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .homeIsRequired:
      return self.navigateToHome()

    case .filterIsRequired:
      return self.navigateToFilter()

    default: return .none
    }
  }
}

private extension HomeFlow {
  func navigateToHome() -> FlowContributors {
    let homeVC = HomeViewController()
    let homeReactor = HomeViewReactor()
    homeVC.reactor = homeReactor
    self.rootViewController.pushViewController(homeVC, animated: true)

    return .one(
      flowContributor: .contribute(
        withNextPresentable: homeVC,
        withNextStepper: homeReactor
      ))
  }

  func navigateToFilter() -> FlowContributors {
    let filterVC = BaseBottomSheetViewController()
    self.rootViewController.present(filterVC, animated: true)

    return .none
  }
}
