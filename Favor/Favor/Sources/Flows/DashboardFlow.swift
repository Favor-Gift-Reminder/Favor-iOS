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
final class DashboardFlow: Flow {
  
  var root: Presentable { self.rootViewController }
  
  let rootViewController = FavorTabBarController()

  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .tabBarIsRequired:
      return self.navigateToDashBoard()

    case .giftManagementIsRequired:
      return self.navigateToNewGift()

    default:
      return .none
    }
  }
}

private extension DashboardFlow {
  func navigateToDashBoard() -> FlowContributors {
    let homeFlow = HomeFlow()
    let myPageFlow = MyPageFlow()

    Flows.use(
      homeFlow,
      myPageFlow,
      when: .ready
    ) { [unowned self] (homeNC: BaseNavigationController, myPageNC: BaseNavigationController) in
      let navigationControllers: [BaseNavigationController] = [homeNC, myPageNC]
      self.rootViewController.setViewControllers(navigationControllers, animated: false)
    }
    
    return .multiple(flowContributors: [
      .contribute(
        withNextPresentable: homeFlow,
        withNextStepper: OneStepper(withSingleStep: AppStep.homeIsRequired)
      ),
      .contribute(withNext: self.rootViewController),
      .contribute(
        withNextPresentable: myPageFlow,
        withNextStepper: OneStepper(withSingleStep: AppStep.myPageIsRequired)
      )
    ])
  }
  
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
