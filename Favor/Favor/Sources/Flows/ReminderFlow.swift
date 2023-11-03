//
//  ReminderFlow.swift
//  Favor
//
//  Created by 이창준 on 2023/03/11.
//

import UIKit

import FavorKit
import RxFlow

@MainActor
final class ReminderFlow: Flow {

  // MARK: - Properties

  var root: Presentable { self.rootViewController }
  private let rootViewController: BaseNavigationController

  // MARK: - Initializer

  init(rootViewController: BaseNavigationController) {
    self.rootViewController = rootViewController
  }
  
  // MARK: - Navigate
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .reminderIsRequired:
      return self.navigateToReminder()

    case .newReminderIsRequired:
      return self.navigateToNewReminder()
      
    case .reminderDetailIsRequired(let reminder):
      return self.navigateToReminderDetail(reminder: reminder)
      
    case .reminderEditIsRequired(let reminder):
      return self.navigateToEditReminder(reminder: reminder)
      
    case .reminderEditIsComplete(let message):
      return self.popFromReminderEdit(message)

    case .reminderIsComplete:
      return .end(forwardToParentFlowWithStep: AppStep.dashboardIsRequired)
      
    case .friendSelectorIsRequired(let friends):
      return self.navigateToFriendSelector(friends)
      
    case .friendSelectorIsComplete(let friends):
      return self.popFromFriendSelector(friends)

    default: return .none
    }
  }
}

// MARK: - Navigates

private extension ReminderFlow {
  func navigateToReminder() -> FlowContributors {
    let reminderVC = ReminderViewController()
    let reminderReactor = ReminderViewReactor()
    reminderVC.reactor = reminderReactor
    reminderVC.hidesBottomBarWhenPushed = true

    self.rootViewController.pushViewController(reminderVC, animated: true)

    return .one(flowContributor: .contribute(
      withNextPresentable: reminderVC,
      withNextStepper: reminderReactor
    ))
  }
  
  func navigateToNewReminder() -> FlowContributors {
    let newReminderVC = ReminderEditViewController()
    let newReminderReactor = ReminderEditViewReactor(.new)
    newReminderVC.reactor = newReminderReactor
    newReminderVC.isEditable = true
    
    self.rootViewController.pushViewController(newReminderVC, animated: true)
    
    return .one(flowContributor: .contribute(
      withNextPresentable: newReminderVC,
      withNextStepper: newReminderReactor
    ))
  }
  
  func navigateToReminderDetail(reminder: Reminder) -> FlowContributors {
    let reminderDetailVC = ReminderDetailViewController()
    let reminderDetailReactor = ReminderDetailViewReactor(reminder: reminder)
    reminderDetailVC.reactor = reminderDetailReactor
    reminderDetailVC.isEditable = false

    self.rootViewController.pushViewController(reminderDetailVC, animated: true)

    return .one(flowContributor: .contribute(
      withNextPresentable: reminderDetailVC,
      withNextStepper: reminderDetailReactor
    ))
  }
  
  func navigateToEditReminder(reminder: Reminder) -> FlowContributors {
    let reminderEditVC = ReminderEditViewController()
    let reminderEditReactor = ReminderEditViewReactor(reminder: reminder)
    reminderEditVC.reactor = reminderEditReactor
    reminderEditVC.isEditable = true

    self.rootViewController.pushViewController(reminderEditVC, animated: true)
    
    return .one(flowContributor: .contribute(
      withNextPresentable: reminderEditVC,
      withNextStepper: reminderEditReactor
    ))
  }
  
  func popFromReminderEdit(_ message: ToastMessage) -> FlowContributors {
    if self.rootViewController.topViewController is ReminderEditViewController {
      self.rootViewController.popViewController(animated: true)
      guard
        let reminderVC = self.rootViewController.topViewController as? ReminderViewController
      else { return .none }
      reminderVC.viewNeedsLoaded(with: message)
    }
    
    return .none
  }
  
  func popFromFriendSelector(_ friends: [Friend]) -> FlowContributors {
    if self.rootViewController.topViewController is ReminderEditViewController {
      self.rootViewController.popViewController(animated: true)
      
      guard
        let reminderEditVC = self.rootViewController.topViewController as? ReminderEditViewController,
        let friend = friends.first
      else { return .none }
      
      reminderEditVC.reactor?.action.onNext(.friendDidChange(friend))
    }
    
    return .none
  }
  
  func navigateToFriendSelector(_ friends: [Friend]) -> FlowContributors {
    let friendSelectorVC = FriendSelectorViewController()
    let friendSelectorReactor = FriendSelectorViewReactor(.reminder, selectedFriends: friends)
    friendSelectorVC.reactor = friendSelectorReactor
    
    self.rootViewController.pushViewController(friendSelectorVC, animated: true)
    
    return .one(flowContributor: .contribute(
      withNextPresentable: friendSelectorVC,
      withNextStepper: friendSelectorReactor
    ))
  }
}
