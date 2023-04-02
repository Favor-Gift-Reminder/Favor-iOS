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

  var root: Presentable { self.rootViewController }

  let rootViewController = BaseNavigationController()

  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .homeIsRequired:
      return self.navigateToHome()

    case .filterIsRequired(let sortType):
      return self.navigateToFilter(sortedBy: sortType)

    case .filterIsComplete(let sortType):
      return self.dismissFilter(sortedBy: sortType)
      
    case .newGiftIsRequired:
      return self.navigateToGift()

    default:
      return .none
    }
  }
}

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
  
  func navigateToFilter(sortedBy sortType: SortType) -> FlowContributors {
    let filterVC = FilterViewController()
    filterVC.currentSortType = sortType
    self.rootViewController.present(filterVC, animated: true)

    return .one(
      flowContributor: .contribute(
        withNextPresentable: filterVC,
        withNextStepper: filterVC
      ))
  }

  func dismissFilter(sortedBy sortType: SortType) -> FlowContributors {
    self.rootViewController.topViewController?.dismiss(animated: true) {
      guard let homeVC = self.rootViewController.topViewController as? HomeViewController else {
        return
      }
      // TODO: Realm DB 구현하며 Sort, Filter 방식 변경
      homeVC.reactor?.currentSortType.accept(sortType)
    }
    return .none
  }
}
