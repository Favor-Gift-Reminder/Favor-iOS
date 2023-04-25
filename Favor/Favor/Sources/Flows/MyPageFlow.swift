//
//  MyPageFlow.swift
//  Favor
//
//  Created by 이창준 on 2023/02/10.
//

import UIKit

import FavorKit
import RxFlow

final class MyPageFlow: Flow {
  
  var root: Presentable { self.rootViewController }
  
  private lazy var rootViewController: BaseNavigationController = {
    let navigationController = BaseNavigationController()
    navigationController.isNavigationBarHidden = true
    return navigationController
  }()
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .myPageIsRequired:
      return self.navigateToMyPage()

    case .editMyPageIsRequired(let user):
      return self.navigateToEditMyPage(with: user)

    case .settingIsRequired:
      return self.navigateToSetting()

    case .friendIsRequired:
      return self.navigateToFriend()

    default:
      return .none
    }
  }
  
  private func navigateToMyPage() -> FlowContributors {
    let myPageVC = MyPageViewController()
    let myPageReactor = MyPageViewReactor()
    myPageVC.reactor = myPageReactor
    self.rootViewController.setViewControllers([myPageVC], animated: true)
    return .one(flowContributor: .contribute(
      withNextPresentable: myPageVC,
      withNextStepper: myPageReactor
    ))
  }

  private func navigateToEditMyPage(with user: User) -> FlowContributors {
    let editMyPageVC = EditMyPageViewController()
    let editMyPageReactor = EditMyPageViewReactor(user: user)
    editMyPageVC.reactor = editMyPageReactor
    self.rootViewController.pushViewController(editMyPageVC, animated: true)
    return .one(flowContributor: .contribute(
      withNextPresentable: editMyPageVC,
      withNextStepper: editMyPageReactor
    ))
  }

  private func navigateToSetting() -> FlowContributors {
    return .none
  }

  private func navigateToFriend() -> FlowContributors {
    let friendVC = FriendViewController()
    let friendReactor = FriendViewReactor()
    friendVC.reactor = friendReactor
    self.rootViewController.pushViewController(friendVC, animated: true)

    return .one(flowContributor: .contribute(
      withNextPresentable: friendVC,
      withNextStepper: friendReactor
    ))
  }
}
