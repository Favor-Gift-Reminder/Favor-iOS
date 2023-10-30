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
  
  var root: Presentable { self.rootViewController }
  
  private let rootViewController = BaseNavigationController()
  
  // MARK: - Navigate
  
  @MainActor
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .giftManagementIsRequired:
      return self.navigateToNewGift()
      
    case .friendSelectorIsRequired(let friends):
      return self.navigateToFriendSelection(friends: friends)
      
    case .friendManagementIsRequired:
      return self.navigateToFriendManagement()
      
    case .friendManagementIsComplete(let friendName):
      return self.popToFriendSelection(friendName: friendName)
       
    case .friendSelectorIsComplete(let friends):
      return self.popFromFriendSelection(friends: friends)
      
    case .giftManagementIsCompleteWithNoChanges:
      return self.popToTabBar()
      
    case .newGiftIsComplete(let gift):
      return self.popToTabBar(with: gift)
      
    case let .imagePickerIsRequired(pickerManager, selectionLimit):
      return self.presentToImagePickerVC(pickerManager: pickerManager, selectionLimit: selectionLimit)
      
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
  func navigateToFriendSelection(friends: [Friend]) -> FlowContributors {
    let viewController = FriendSelectionViewController()
    let reactor = FriendSelectorViewReactor(.gift, selectedFriends: friends)
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
  func popToFriendSelection(friendName: String) -> FlowContributors {
    self.rootViewController.popViewController(animated: true)
    ToastManager.shared.showNewToast(FavorToastMessageView(.tempFriendAdded(friendName)))
    guard 
      let friendSelectionVC = self.rootViewController.topViewController as? FriendSelectionViewController
    else { return .none }
    friendSelectionVC.tempFriendAdded(friendName)
    return .none
  }
  
  @MainActor
  func popToTabBar(with gift: Gift? = nil) -> FlowContributors {
    self.rootViewController.dismiss(animated: true)
    return .end(forwardToParentFlowWithStep: AppStep.dashboardIsRequired)
  }
  
  @MainActor
  func popFromFriendSelection(friends: [Friend]) -> FlowContributors {
    self.rootViewController.popViewController(animated: true)
    guard 
      let giftManagementVC = self.rootViewController.topViewController as? GiftManagementViewController
    else { return .none }
    giftManagementVC.friendsDidAdd(friends)
    return .none
  }
  
  @MainActor
  func presentToImagePickerVC(pickerManager: PHPickerManager, selectionLimit: Int) -> FlowContributors {
    pickerManager.present(selectionLimit: selectionLimit)
    return .none
  }
}
