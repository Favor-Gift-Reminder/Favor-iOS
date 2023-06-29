//
//  DashboardFlow.swift
//  Favor
//
//  Created by 김응철 on 2023/02/02.
//

import UIKit

import FavorKit
import RxFlow

@MainActor
public final class DashboardFlow: Flow {

  // MARK: - Properties

  public var root: Presentable { self.rootViewController }
  
  let rootViewController: BaseNavigationController

  // MARK: - Initializer

  init(_ rootViewController: BaseNavigationController) {
    self.rootViewController = rootViewController
  }

  // MARK: - Navigate

  public func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .giftManagementIsRequired:
      return self.navigateToNewGift()
    default:
      return .none
    }
  }
}

// MARK: - Navigates

private extension DashboardFlow {
  func navigateToNewGift() -> FlowContributors {
    let newGiftFlow = NewGiftFlow()

    Flows.use(newGiftFlow, when: .ready) { [unowned self] root in
      DispatchQueue.main.async {
        root.modalPresentationStyle = .overFullScreen
        self.rootViewController.present(root, animated: true)
      }
    }

    return .one(flowContributor: .contribute(
      withNextPresentable: newGiftFlow,
      withNextStepper: OneStepper(withSingleStep: AppStep.giftManagementIsRequired())
    ))
  }
}
