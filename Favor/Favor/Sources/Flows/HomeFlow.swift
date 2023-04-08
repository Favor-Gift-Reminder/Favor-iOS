//
//  HomeFlow.swift
//  Favor
//
//  Created by 이창준 on 2023/03/11.
//

import UIKit

import FavorKit
import RxCocoa
import RxFlow
import RxSwift

final class HomeFlow: Flow {

  // MARK: - Properties

  var root: Presentable { self.rootViewController }
  let rootViewController = BaseNavigationController()

  // MARK: - Navigate

  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .homeIsRequired:
      return self.navigateToHome()
      
    case .newGiftIsRequired:
      return self.navigateToGift()

    case .searchIsRequired:
      return self.navigateToSearch()

    default: return .none
    }
  }
}

// MARK: - Navigates

private extension HomeFlow {
  func navigateToGift() -> FlowContributors {
    let giftFlow = GiftFlow(self.rootViewController)
    
    return .one(flowContributor: .contribute(
      withNextPresentable: giftFlow,
      withNextStepper: OneStepper(withSingleStep: AppStep.newGiftIsRequired)
    ))
  }
  
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

  func navigateToSearch() -> FlowContributors {
    let searchFlow = SearchFlow(rootViewController: self.rootViewController)

    return .one(
      flowContributor: .contribute(
        withNextPresentable: searchFlow,
        withNextStepper: OneStepper(withSingleStep: AppStep.searchIsRequired)
      )
    )
  }
}
