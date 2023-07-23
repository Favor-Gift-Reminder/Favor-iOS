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

@MainActor
final class HomeFlow: Flow {

  // MARK: - Properties

  var root: Presentable { self.rootViewController }
  let rootViewController = BaseNavigationController()
  
  var filterBottomSheet: FilterBottomSheet?

  // MARK: - Navigate
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .homeIsRequired:
      return self.navigateToHome()

    case .searchIsRequired:
      return self.navigateToSearch()

    case .reminderIsRequired:
      return self.navigateToReminder()

    case .filterBottomSheetIsRequired(let sortType):
      return self.navigateToFilter(sortedBy: sortType)

    case .giftDetailIsRequired(let gift):
      return self.navigateToGift(with: gift)

    default: return .none
    }
  }
}

// MARK: - Navigates

private extension HomeFlow {
  func navigateToHome() -> FlowContributors {
    let homeVC = HomeViewController()
    let homeReactor = HomeViewReactor()
    homeVC.reactor = homeReactor
    self.rootViewController.pushViewController(homeVC, animated: true)

    return .one(flowContributor: .contribute(
      withNextPresentable: homeVC,
      withNextStepper: homeReactor
    ))
  }
  
  func navigateToSearch() -> FlowContributors {
    let searchFlow = SearchFlow(rootViewController: self.rootViewController)
    
    return .one(flowContributor: .contribute(
      withNextPresentable: searchFlow,
      withNextStepper: OneStepper(withSingleStep: AppStep.searchIsRequired)
    ))
  }

  func navigateToReminder() -> FlowContributors {
    let reminderFlow = ReminderFlow(rootViewController: self.rootViewController)

    return .one(flowContributor: .contribute(
      withNextPresentable: reminderFlow,
      withNextStepper: OneStepper(withSingleStep: AppStep.reminderIsRequired)
    ))
  }

  func navigateToGift(with gift: Gift) -> FlowContributors {
    let giftFlow = GiftFlow(rootViewController: self.rootViewController)

    return .one(flowContributor: .contribute(
      withNextPresentable: giftFlow,
      withNextStepper: OneStepper(withSingleStep: AppStep.giftDetailIsRequired(gift))
    ))
  }

  func navigateToFilter(sortedBy sortType: SortType) -> FlowContributors {
    let filterBottomSheet = FilterBottomSheet()
    filterBottomSheet.currentSortType = sortType
    filterBottomSheet.modalPresentationStyle = .overFullScreen
    self.rootViewController.present(filterBottomSheet, animated: false)
    self.filterBottomSheet = filterBottomSheet

    return .one(flowContributor: .contribute(
      withNextPresentable: filterBottomSheet,
      withNextStepper: filterBottomSheet
    ))
  }
  
  func dismissFilter(sortedBy sortType: SortType) -> FlowContributors {
    self.filterBottomSheet?.animateDismissView()
    self.filterBottomSheet = nil
    
    guard let homeVC = self.rootViewController.topViewController as? HomeViewController else {
      return .none
    }
    // TODO: Realm DB 구현하며 Sort, Filter 방식 변경
//    homeVC.reactor?.currentSortType.accept(sortType)
//    homeVC.filterDidEnded()
    return .none
  }
}
