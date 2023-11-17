//
//  FriendPageFlow.swift
//  Favor
//
//  Created by 김응철 on 2023/05/29.
//

import UIKit

import FavorKit
import RxFlow

final class FriendPageFlow: Flow {
  
  // MARK: - Properties
  
  var root: Presentable { self.rootViewController }
  private let rootViewController: BaseNavigationController
  private var memoBottomSheet: MemoBottomSheet?
  
  // MARK: - Initializer
  
  init(rootViewController: BaseNavigationController) {
    self.rootViewController = rootViewController
  }
  
  // MARK: - Functions
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .friendPageIsRequired(let friend):
      return self.navigateToFriendPage(friend)
      
    case .memoBottomSheetIsRequired(let memo):
      return self.navigateToMemoBottomSheet(with: memo)
      
    case .memoBottomSheetIsComplete(let memo):
      self.dismissMemoBottomSheet(memo)
      return .none
      
    case .newAnniversaryIsRequired:
      return self.navigateToAnniversaryManagement()
      
    case .anniversaryListIsRequired(let anniversaryListType):
      return self.navigateToAnniversaryList(anniversaryListType)
      
    default:
      return .none
    }
  }
}

extension FriendPageFlow {
  private func navigateToFriendPage(_ friend: Friend) -> FlowContributors {
    let friendPageVC = FriendPageViewController()
    let reactor = FriendPageViewReactor(friend)
    friendPageVC.reactor = reactor
    friendPageVC.hidesBottomBarWhenPushed = true
    
    self.rootViewController.setupNavigationAppearance()
    self.rootViewController.pushViewController(friendPageVC, animated: true)
    
    return .one(flowContributor: .contribute(
      withNextPresentable: friendPageVC,
      withNextStepper: reactor
    ))
  }
  
  private func navigateToMemoBottomSheet(with memo: String?) -> FlowContributors {
    let memoBottomSheet = MemoBottomSheet(memo)
    memoBottomSheet.modalPresentationStyle = .overFullScreen
    self.memoBottomSheet = memoBottomSheet
    self.rootViewController.present(memoBottomSheet, animated: false)
    return .one(flowContributor: .contribute(withNext: memoBottomSheet))
  }
  
  private func dismissMemoBottomSheet(_ memo: String?) {
    self.memoBottomSheet?.dismissBottomSheet()
    guard let friendPageVC = self.rootViewController.topViewController as? FriendPageViewController
    else { return }
    friendPageVC.memoBottomSheetCompletion(memo: memo)
  }
  
  private func navigateToAnniversaryManagement() -> FlowContributors {
    let flow = AnniversaryFlow(rootViewController: self.rootViewController)
    
    return .one(flowContributor: .contribute(
      withNextPresentable: flow,
      withNextStepper: OneStepper(withSingleStep: AppStep.newAnniversaryIsRequired)
    ))
  }
  
  private func navigateToAnniversaryList(_ anniversaryListType: AnniversaryListType) -> FlowContributors {
    let flow = AnniversaryFlow(rootViewController: self.rootViewController)
    
    return .one(flowContributor: .contribute(
      withNextPresentable: flow,
      withNextStepper: OneStepper(withSingleStep: AppStep.anniversaryListIsRequired(anniversaryListType))
    ))
  }
}
