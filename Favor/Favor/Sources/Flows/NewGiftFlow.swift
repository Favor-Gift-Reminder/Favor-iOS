//
//  GiftFlow.swift
//  Favor
//
//  Created by 김응철 on 2023/03/30.
//

import UIKit

import FavorKit
import RxFlow

final class NewGiftFlow: Flow {

  // MARK: - Properties
  
  var root: Presentable {
    self.rootViewController
  }

  private let rootViewController = BaseNavigationController()
  
  // MARK: - Navigate
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .imagePickerIsRequired(let manager):
      return self.presentPHPicker(manager: manager)
      
    case .newGiftIsRequired:
      return self.navigateToNewGift()

    case .newGiftIsComplete:
      return self.popToTabBar()
      
    case .newGiftFriendIsRequired:
      return self.navigateToNewGiftFriend()
      
    case .friendManagementIsRequired:
      return self.navigateToFriendManagement()
      
    default:
      return .none
    }
  }
}

// MARK: - Navigates

private extension NewGiftFlow {
  func navigateToNewGift() -> FlowContributors {
    let giftManagementVC = GiftManagementViewController()
    let giftManagementReactor = GiftManagementViewReactor(pickerManager: PHPickerManager())
    giftManagementVC.viewType = .new
    giftManagementVC.reactor = giftManagementReactor

    DispatchQueue.main.async {
      self.rootViewController.pushViewController(giftManagementVC, animated: false)
    }
    
    return .one(flowContributor: .contribute(
      withNextPresentable: giftManagementVC,
      withNextStepper: giftManagementReactor
    ))
  }
  
  func navigateToNewGiftFriend() -> FlowContributors {
    let viewController = NewGiftFriendViewController()
    let reactor = NewGiftFriendViewReactor()
    viewController.reactor = reactor
    self.rootViewController.pushViewController(viewController, animated: true)
    
    return .one(flowContributor: .contribute(
      withNextPresentable: viewController,
      withNextStepper: reactor
    ))
  }
  
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

  func popToTabBar() -> FlowContributors {
    self.rootViewController.dismiss(animated: true)

    return .end(forwardToParentFlowWithStep: AppStep.tabBarIsRequired)
  }
  
  func presentPHPicker(manager: PHPickerManager) -> FlowContributors {
    manager.presentPHPicker(at: self.rootViewController)
    return .none
  }
}
