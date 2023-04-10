//
//  GiftFlow.swift
//  Favor
//
//  Created by 김응철 on 2023/03/30.
//

import UIKit

import FavorKit
import RxFlow

final class NewGiftFlow: Flow {

  // MARK: - Properties
  
  var root: Presentable {
    self.rootViewController
  }

  private let rootViewController = BaseNavigationController()

  // MARK: - Navigate
  
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

// MARK: - Navigates

private extension NewGiftFlow {
  func navigateToNewGift() -> FlowContributors {
    let newGiftViewController = NewGiftViewController()
    let newGiftReactor = NewGiftViewReactor(pickerManager: PHPickerManager())
    newGiftViewController.reactor = newGiftReactor
    self.rootViewController.pushViewController(newGiftViewController, animated: false)
    
    return .one(flowContributor: .contribute(
      withNextPresentable: newGiftViewController,
      withNextStepper: newGiftReactor
    ))
  }
  
  func presentPHPicker(manager: PHPickerManager) -> FlowContributors {
    manager.presentPHPicker(at: self.rootViewController)
    return .none
  }
}
