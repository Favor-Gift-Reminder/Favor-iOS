//
//  GiftFlow.swift
//  Favor
//
//  Created by 김응철 on 2023/03/30.
//

import UIKit

import FavorKit
import RxFlow

@MainActor
final class NewGiftFlow: Flow {

  // MARK: - Properties
  
  var root: Presentable {
    self.rootViewController
  }

  private let rootViewController = BaseNavigationController()
  
  // MARK: - Navigate
  
  @MainActor
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .giftManagementIsRequired:
      return self.navigateToNewGift()
      
    case .newGiftFriendIsRequired:
      return self.navigateToNewGiftFriend()
      
    case .friendManagementIsRequired:
      return self.navigateToFriendManagement()

    case .giftManagementIsCompleteWithNoChanges:
      return self.popToTabBar()

    case .newGiftIsComplete(let gift):
      return self.popToTabBar(with: gift)
      
    default:
      return .none
    }
  }
}

// MARK: - Navigates

private extension NewGiftFlow {
  @MainActor
  func navigateToNewGift() -> FlowContributors {
    let giftManagementVC = GiftManagementViewController()
    let giftManagementReactor = GiftManagementViewReactor(.new)
    giftManagementVC.reactor = giftManagementReactor
    giftManagementVC.hidesBottomBarWhenPushed = true

    self.rootViewController.pushViewController(giftManagementVC, animated: false)
    
    return .one(flowContributor: .contribute(
      withNextPresentable: giftManagementVC,
      withNextStepper: giftManagementReactor
    ))
  }
  
  @MainActor
  func navigateToNewGiftFriend() -> FlowContributors {
    let viewController = FriendSelectionViewController()
    let reactor = FriendSelectorViewReactor(.gift)
    viewController.reactor = reactor
    self.rootViewController.pushViewController(viewController, animated: true)
    
    return .one(flowContributor: .contribute(
      withNextPresentable: viewController,
      withNextStepper: reactor
    ))
  }

  @MainActor
  func navigateToFriendManagement() -> FlowContributors {
    let viewController = FriendManagementViewController(.new)
    let reactor = FriendManagementViewReactor()
    viewController.reactor = reactor
    self.rootViewController.pushViewController(viewController, animated: true)
    
    return .one(flowContributor: .contribute(
      withNextPresentable: viewController,
      withNextStepper: reactor
    ))
  }

  @MainActor
  func popToTabBar(with gift: Gift? = nil) -> FlowContributors {
    self.rootViewController.dismiss(animated: true)

    return .end(forwardToParentFlowWithStep: AppStep.dashboardIsRequired)
  }
}
