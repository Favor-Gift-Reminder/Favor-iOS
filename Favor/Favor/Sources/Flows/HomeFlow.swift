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

    case .reminderDetailIsRequired(let reminder):
      let reminderFlow = ReminderFlow(rootViewController: self.rootViewController)
      return .one(flowContributor: .contribute(
        withNextPresentable: reminderFlow,
        withNextStepper: OneStepper(withSingleStep: AppStep.reminderDetailIsRequired(reminder))
      ))
      
    case .reminderIsRequired:
      return self.navigateToReminder()

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
    let flow = GiftDetailFlow(rootViewController: self.rootViewController)
    return .one(flowContributor: .contribute(
      withNextPresentable: flow,
      withNextStepper: OneStepper(withSingleStep: AppStep.giftDetailIsRequired(gift))
    ))
  }
}
