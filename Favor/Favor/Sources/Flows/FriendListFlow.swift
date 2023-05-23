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
    friendListVC.reactor = friendListReactor
    friendListVC.title = "내 친구"
    friendListVC.viewType = .list

    DispatchQueue.main.async {
      self.rootViewController.pushViewController(friendListVC, animated: true)
    }

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

    DispatchQueue.main.async {
      self.rootViewController.pushViewController(editFriendVC, animated: true)
    }

    return .one(flowContributor: .contribute(
      withNextPresentable: editFriendVC,
      withNextStepper: editFriendReactor
    ))
  }

  func navigateToMyPage() -> FlowContributors {
    DispatchQueue.main.async {
      self.rootViewController.popViewController(animated: true)
    }
    return .end(forwardToParentFlowWithStep: AppStep.friendListIsComplete)
  }
}
