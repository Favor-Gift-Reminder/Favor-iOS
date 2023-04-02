//
//  GiftFlow.swift
//  Favor
//
//  Created by 김응철 on 2023/03/30.
//

import UIKit

import FavorKit
import RxFlow

final class GiftFlow: Flow {
  
  var root: Presentable {
    self.rootViewController
  }
  
  private let rootViewController: BaseNavigationController
  
  init(_ navigationController: BaseNavigationController) {
    self.rootViewController = navigationController
  }
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .imagePickerIsRequired(let manager):
      return self.presentPHPicker(manager: manager)
      
    case .newGiftIsRequired:
      return self.navigateToNewGift()
      
    default:
      return .none
    }
  }
}

private extension GiftFlow {
  func navigateToNewGift() -> FlowContributors {
    let viewController = NewGiftViewController()
    let reactor = NewGiftViewReactor(pickerManager: PHPickerManager())
    viewController.reactor = reactor
    viewController.hidesBottomBarWhenPushed = true
    self.rootViewController.pushViewController(viewController, animated: true)
    
    return .one(flowContributor: .contribute(
      withNextPresentable: viewController,
      withNextStepper: reactor
    ))
  }
  
  func presentPHPicker(manager: PHPickerManager) -> FlowContributors {
    manager.presentPHPicker(at: self.rootViewController)
    return .none
  }
}
