//
//  FriendPageFlow.swift
//  Favor
//
//  Created by 김응철 on 2023/05/19.
//

import UIKit

import FavorKit
import RxFlow

final class FriendFlow: Flow {
  
  // MARK: - Properties
  
  var root: Presentable { self.rootViewController }
  
  let rootViewController = BaseNavigationController()
  
  // MARK: - Navigate
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    switch step {
    case .friendManagementIsRequired(let viewControllerType):
      return self.navigateToFriendManagement(viewControllerType)
    default:
      return .none
    }
  }
}

private extension FriendFlow {
  func navigateToFriendManagement(
    _ viewControllerType: FriendManagementViewController.ViewControllerType
  ) -> FlowContributors {
    let viewController = FriendManagementViewController(viewControllerType)
    let reactor = FriendManagementViewReactor()
    viewController.reactor = reactor
    return .one(flowContributor: .contribute(
      withNextPresentable: viewController,
      withNextStepper: reactor
    ))
  }
}
