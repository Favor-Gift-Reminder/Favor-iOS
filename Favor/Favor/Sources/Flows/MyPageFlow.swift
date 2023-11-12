//
//  MyPageFlow.swift
//  Favor
//
//  Created by 이창준 on 2023/02/10.
//

import UIKit

import FavorKit
import RxFlow

@MainActor
final class MyPageFlow: Flow {
  
  var root: Presentable { self.rootViewController }
  
  private let rootViewController: BaseNavigationController = {
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

    case .editMyPageIsComplete:
      self.rootViewController.popViewController(animated: true)
      return .none
      
    case .settingsIsRequired:
      return self.navigateToSettings()

    case .anniversaryListIsRequired:
      return self.navigateToAnniversaryList()

    case .friendListIsRequired:
      return self.navigateToFriendList()
      
    case .friendPageIsRequired(let friend):
      return self.navigateToFriendPage(friend)
      
    case .newAnniversaryIsRequired:
      return self.navigateToNewAnniversary()

    case .wayBackToRootIsRequired:
      return .one(flowContributor: .forwardToParentFlow(withStep: AppStep.wayBackToRootIsRequired))
      
    case let .imagePickerIsRequired(pickerManager, _):
      return self.navigateToImagePicker(pickerManager)

    default:
      return .none
    }
  }
}

extension MyPageFlow {
  private func navigateToMyPage() -> FlowContributors {
    let myPageVC = MyPageViewController()
    let myPageReactor = MyPageViewReactor()
    myPageVC.reactor = myPageReactor

    DispatchQueue.main.async {
      self.rootViewController.setViewControllers([myPageVC], animated: true)
    }

    return .one(flowContributor: .contribute(
      withNextPresentable: myPageVC,
      withNextStepper: myPageReactor
    ))
  }
  
  private func navigateToEditMyPage(with user: User) -> FlowContributors {
    let editMyPageVC = EditMyPageViewController()
    editMyPageVC.hidesBottomBarWhenPushed = true
    let editMyPageReactor = EditMyPageViewReactor(user: user)
    editMyPageVC.reactor = editMyPageReactor

    DispatchQueue.main.async {
      self.rootViewController.setupNavigationAppearance()
      self.rootViewController.navigationBar.tintColor = .favorColor(.white)
      self.rootViewController.pushViewController(editMyPageVC, animated: true)
    }
    
    return .one(flowContributor: .contribute(
      withNextPresentable: editMyPageVC,
      withNextStepper: editMyPageReactor
    ))
  }

  private func navigateToSettings() -> FlowContributors {
    let settingsFlow = SettingsFlow(rootViewController: self.rootViewController)

    return .one(flowContributor: .contribute(
      withNextPresentable: settingsFlow,
      withNextStepper: OneStepper(withSingleStep: AppStep.settingsIsRequired)
    ))
  }
  
  private func navigateToAnniversaryList() -> FlowContributors {
    let anniversaryListFlow = AnniversaryFlow(rootViewController: self.rootViewController)
    
    return .one(flowContributor: .contribute(
      withNextPresentable: anniversaryListFlow,
      withNextStepper: OneStepper(withSingleStep: AppStep.anniversaryListIsRequired(.mine))
    ))
  }

  private func navigateToFriendList() -> FlowContributors {
    let friendListFlow = FriendListFlow(rootViewController: self.rootViewController)

    return .one(flowContributor: .contribute(
      withNextPresentable: friendListFlow,
      withNextStepper: OneStepper(withSingleStep: AppStep.friendListIsRequired)
    ))
  }

  private func navigateToFriendPage(_ friend: Friend) -> FlowContributors {
    let friendPageFlow = FriendPageFlow(rootViewController: self.rootViewController)
    
    return .one(flowContributor: .contribute(
      withNextPresentable: friendPageFlow,
      withNextStepper: OneStepper(withSingleStep: AppStep.friendPageIsRequired(friend))
    ))
  }
  
  private func navigateToNewAnniversary() -> FlowContributors {
    let anniversaryFlow = AnniversaryFlow(rootViewController: self.rootViewController)
    
    return .one(flowContributor: .contribute(
      withNextPresentable: anniversaryFlow,
      withNextStepper: OneStepper(withSingleStep: AppStep.newAnniversaryIsRequired)
    ))
  }
  
  private func navigateToImagePicker(_ pickerManager: PHPickerManager) -> FlowContributors {
    pickerManager.present(selectionLimit: 1)
    
    return .none
  }
}
