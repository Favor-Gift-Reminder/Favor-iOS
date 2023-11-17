//
//  GiftDetailFlow.swift
//  Favor
//
//  Created by 김응철 on 11/16/23.
//

import Foundation

import FavorKit
import RxFlow

final class GiftDetailFlow: Flow {
  
  // MARK: - Properties
  
  var root: Presentable { self.rootViewController }
  
  private let rootViewController: BaseNavigationController
  
  // MARK: - Initializer
  
  init(rootViewController: BaseNavigationController) {
    self.rootViewController = rootViewController
  }
  
  // MARK: - Navigate
  
  @MainActor 
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .giftDetailIsRequired(let gift):
      let viewController = GiftDetailViewController()
      let reactor = GiftDetailViewReactor(gift: gift)
      viewController.reactor = reactor
      viewController.hidesBottomBarWhenPushed = true
      self.rootViewController.pushViewController(viewController, animated: true)
      
      return .one(flowContributor: .contribute(
        withNextPresentable: viewController,
        withNextStepper: reactor
      ))
      
    case .giftDetailIsComplete(let gift):
      self.rootViewController.popViewController(animated: true)
      ToastManager.shared.showNewToast(.init(.giftDeleted(gift.name)))
      return .end(forwardToParentFlowWithStep: AppStep.doNothing)
      
    case .giftManagementIsRequired(let gift):
      let flow = GiftManagementFlow(rootViewController: self.rootViewController)
      return .one(flowContributor: .contribute(
        withNextPresentable: flow,
        withNextStepper: OneStepper(withSingleStep: AppStep.giftManagementIsRequired(gift))
      ))
      
    case let .giftDetailPhotoIsRequired(items, count):
      guard let giftDetailVC = self.rootViewController
        .topViewController as? GiftDetailViewController
      else { return .none }
      giftDetailVC.presentImageGallery(index: items, total: count)
      return .none
      
    case .giftShareIsRequired(let gift):
      let viewController = GiftShareViewController()
      let reactor = GiftShareViewReactor(gift: gift)
      viewController.reactor = reactor
      viewController.title = "선물 한 컷"
      self.rootViewController.pushViewController(viewController, animated: true)
      return .one(flowContributor: .contribute(
        withNextPresentable: viewController,
        withNextStepper: reactor
      ))
      
    case .searchCategoryResultIsRequired(let category):
      let flow = SearchFlow(rootViewController: self.rootViewController)
      return .one(flowContributor: .contribute(
        withNextPresentable: flow,
        withNextStepper: OneStepper(withSingleStep: AppStep.searchCategoryResultIsRequired(category))
      ))
      
    case .searchEmotionResultIsRequired(let emotion):
      let flow = SearchFlow(rootViewController: self.rootViewController)
      return .one(flowContributor: .contribute(
        withNextPresentable: flow,
        withNextStepper: OneStepper(withSingleStep: AppStep.searchEmotionResultIsRequired(emotion))
      ))
      
    case .giftDetailFriendsBottomSheetIsRequired(let friends):
      let viewController = GiftFriendsBottomSheet()
      viewController.friends = friends
      viewController.modalPresentationStyle = .overFullScreen
      self.rootViewController.present(viewController, animated: false)
      return .one(flowContributor: .contribute(withNext: viewController))
      
    default:
      return .none
    }
  }
}
