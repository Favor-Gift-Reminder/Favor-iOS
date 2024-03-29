//
//  FriendListFlow.swift
//  Favor
//
//  Created by 이창준 on 2023/05/15.
//

import UIKit

import FavorKit
import RxFlow

final class FriendListFlow: Flow {

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
    case .friendListIsRequired:
      return self.navigateToFriendList()

    case .editFriendIsRequired:
      return self.navigateToEditFriend()

    case .friendListIsComplete:
      return self.navigateToMyPage()
      
    case .friendPageIsRequired(let friend):
      return self.navigateToFriendPage(with: friend)
      
    case let .friendSelectorIsRequired(friends, viewType):
      let viewController = FriendSelectorViewController()
      let reactor = FriendSelectorViewReactor(viewType, selectedFriends: friends)
      viewController.reactor = reactor
      self.rootViewController.pushViewController(viewController, animated: true)
      return .one(flowContributor: .contribute(
        withNextPresentable: viewController,
        withNextStepper: reactor
      ))
      
    case .friendSelectorIsComplete(let friends):
      self.rootViewController.popViewController(animated: true)
      return .end(forwardToParentFlowWithStep: AppStep.friendSelectorIsComplete(friends))
      
    case .friendManagementIsRequired(let viewType):
      let viewController = FriendManagementViewController(viewType)
      let reactor = FriendManagementViewReactor()
      viewController.reactor = reactor
      self.rootViewController.pushViewController(viewController, animated: true)
      return .one(flowContributor: .contribute(
        withNextPresentable: viewController,
        withNextStepper: reactor
      ))
      
    case .friendManagementIsComplete(let friendName):
      self.rootViewController.popViewController(animated: true)
      guard
        let friendSelectorVC = self.rootViewController
          .topViewController as? FriendSelectorViewController
      else { return .none }
      friendSelectorVC.tempFriendAdded(friendName)
      return .none
      
    default:
      return .none
    }
  }
}

// MARK: - Navigates

private extension FriendListFlow {
  func navigateToFriendList() -> FlowContributors {
    let friendListVC = FriendListViewController()
    let friendListReactor = FriendListViewReactor()
    friendListVC.hidesBottomBarWhenPushed = true
    friendListVC.reactor = friendListReactor
    friendListVC.title = "내 친구"
    friendListVC.viewType = .list

    self.rootViewController.pushViewController(friendListVC, animated: true)

    return .one(flowContributor: .contribute(
      withNextPresentable: friendListVC,
      withNextStepper: friendListReactor
    ))
  }

  private func navigateToEditFriend() -> FlowContributors {
    let editFriendVC = FriendListModifyingViewController()
    let editFriendReactor = FriendListModifyingViewReactor()
    editFriendVC.reactor = editFriendReactor
    editFriendVC.title = "삭제하기"
    editFriendVC.viewType = .edit

    self.rootViewController.pushViewController(editFriendVC, animated: true)

    return .one(flowContributor: .contribute(
      withNextPresentable: editFriendVC,
      withNextStepper: editFriendReactor
    ))
  }

  func navigateToMyPage() -> FlowContributors {
    self.rootViewController.popViewController(animated: true)
    return .end(forwardToParentFlowWithStep: AppStep.friendListIsComplete)
  }
  
  private func navigateToFriendPage(with friend: Friend) -> FlowContributors {
    let friendPageFlow = FriendPageFlow(rootViewController: self.rootViewController)
    
    return .one(flowContributor: .contribute(
      withNextPresentable: friendPageFlow,
      withNextStepper: OneStepper(withSingleStep: AppStep.friendPageIsRequired(friend))
    ))
    
  }
}
