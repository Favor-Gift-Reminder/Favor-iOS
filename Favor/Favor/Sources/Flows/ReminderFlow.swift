//
//  ReminderFlow.swift
//  Favor
//
//  Created by 이창준 on 2023/03/11.
//

import UIKit

import FavorKit
import RxFlow

final class ReminderFlow: Flow {

  var root: Presentable { self.rootViewController }

  let rootViewController = BaseNavigationController()

  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .reminderIsRequired:
      return self.navigateToReminder()

    case .newReminderIsRequired:
      return self.navigateToNewReminder()

    case .newReminderIsComplete:
      return .end(forwardToParentFlowWithStep: AppStep.tabBarIsRequired)

    case .reminderDetailIsRequired:
      return self.navigateToReminderDetail()

    default: return .none
    }
  }
}

private extension ReminderFlow {
  func navigateToReminder() -> FlowContributors {
    let reminderVC = ReminderViewController()
    let reminderReactor = ReminderViewReactor()
    reminderVC.reactor = reminderReactor
    self.rootViewController.pushViewController(reminderVC, animated: true)

    return .one(
      flowContributor: .contribute(
        withNextPresentable: reminderVC,
        withNextStepper: reminderReactor
      ))
  }

  func navigateToNewReminder() -> FlowContributors {
    let newReminderVC = NewReminderViewController()
    let newReminderReactor = NewReminderViewReactor()
    newReminderVC.reactor = newReminderReactor
    self.rootViewController.pushViewController(newReminderVC, animated: true)

    return .one(
      flowContributor: .contribute(
        withNextPresentable: newReminderVC,
        withNextStepper: newReminderReactor
      ))
  }

  func navigateToReminderDetail() -> FlowContributors {
    let reminderDetailVC = ReminderDetailViewController()
    let reminderDetailReactor = ReminderDetailViewReactor()
    reminderDetailVC.reactor = reminderDetailReactor
    self.rootViewController.pushViewController(reminderDetailVC, animated: true)

    return .one(
      flowContributor: .contribute(
        withNextPresentable: reminderDetailVC,
        withNextStepper: reminderDetailReactor
      ))
  }
}
