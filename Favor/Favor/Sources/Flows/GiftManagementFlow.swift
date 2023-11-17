//
//  GiftManagementFlow.swift
//  Favor
//
//  Created by 김응철 on 11/16/23.
//

import Foundation

import FavorKit
import RxFlow

final class GiftManagementFlow: Flow {
  
  // MARK: - Properties
  
  var root: Presentable { self.rootViewController }
  
  private let rootViewController: BaseNavigationController
  
  // MARK: - Init
  
  init(rootViewController: BaseNavigationController? = nil) {
    if let rootViewController {
      self.rootViewController = rootViewController
    } else {
      self.rootViewController = BaseNavigationController()
    }
  }
  
  // MARK: - Navigate
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .giftManagementIsRequired(let gift):
      let viewController = GiftManagementViewController()
      let reactor: GiftManagementViewReactor
      if let gift = gift {
        reactor = .init(.edit, with: gift)
      } else {
        reactor = .init(.new)
      }
      viewController.reactor = reactor
      self.rootViewController.pushViewController(viewController, animated: true)
      return .one(flowContributor: .contribute(
        withNextPresentable: viewController,
        withNextStepper: reactor
      ))
      
    case .newGiftIsComplete:
      self.rootViewController.popViewController(animated: true)
      self.rootViewController.dismiss(animated: true)
      ToastManager.shared.showNewToast(.init(.giftAdded))
      return .end(forwardToParentFlowWithStep: AppStep.doNothing)
      
    case .editGiftIsComplete(let gift):
      self.rootViewController.popViewController(animated: true)
      ToastManager.shared.showNewToast(.init(.giftEdited(gift.name)))
      return .end(forwardToParentFlowWithStep: AppStep.doNothing)
      
    case .giftManagementIsCompleteWithNoChanges:
      self.rootViewController.popViewController(animated: true)
      self.rootViewController.dismiss(animated: true)
      return .end(forwardToParentFlowWithStep: AppStep.doNothing)
      
    case let .imagePickerIsRequired(pickerManager, selectionLimit):
      pickerManager.present(selectionLimit: selectionLimit)
      return .none
      
    case .friendSelectorIsRequired(let friends):
      let viewController = FriendSelectorViewController()
      let reactor = FriendSelectorViewReactor(.gift, selectedFriends: friends)
      viewController.reactor = reactor
      self.rootViewController.pushViewController(viewController, animated: true)
      return .one(flowContributor: .contribute(
        withNextPresentable: viewController,
        withNextStepper: reactor
      ))
      
    case .friendManagementIsRequired:
      let viewController = FriendManagementViewController(.new)
      let reactor = FriendManagementViewReactor()
      viewController.reactor = reactor
      return .one(flowContributor: .contribute(
        withNextPresentable: viewController,
        withNextStepper: reactor
      ))
      
    case .friendManagementIsComplete(let friendName):
      self.rootViewController.popViewController(animated: true)
      guard
        let giftManagementVC = self.rootViewController
          .topViewController as? GiftManagementViewController
      else { return .none }
      giftManagementVC.friendsDidAdd([.init(friendName: friendName)])
      return .none
      
    case .friendSelectorIsComplete(let friends):
      self.rootViewController.popViewController(animated: true)
      guard 
        let giftManagementVC = self.rootViewController.topViewController
          as? GiftManagementViewController 
      else {
        return .none	
      }
      giftManagementVC.friendsDidAdd(friends)
      return .none
      
    default:
      return .none
    }
  }
}
