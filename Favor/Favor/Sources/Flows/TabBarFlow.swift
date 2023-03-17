//
//  TabBarFlow.swift
//  Favor
//
//  Created by 김응철 on 2023/02/02.
//

import UIKit

import FavorKit
import RxFlow

final class TabBarFlow: Flow {
  
  var root: Presentable { self.rootViewController }
  
  let rootViewController = BaseTabBarController()
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .tabBarIsRequired:
      return self.navigateToDashBoard()

    default:
      return .none
    }
  }
}

private extension TabBarFlow {
  func navigateToDashBoard() -> FlowContributors {
    let homeFlow = HomeFlow()
    let reminderFlow = ReminderFlow()
    let myPageFlow = MyPageFlow()

    Flows.use(
      homeFlow,
      reminderFlow,
      myPageFlow,
      when: .created
    ) { [unowned self] (homeNC: BaseNavigationController, reminderNC: BaseNavigationController, myPageNC: BaseNavigationController) in
      let pages = TabBarPage.allCases
      let navigationControllers: [BaseNavigationController] = [homeNC, reminderNC, myPageNC]
      navigationControllers.enumerated().forEach { idx, nc in
        nc.tabBarItem = pages[idx].tabBarItem
      }

      self.rootViewController.setViewControllers(navigationControllers, animated: false)
    }
    
    return .multiple(flowContributors: [
      .contribute(
        withNextPresentable: homeFlow,
        withNextStepper: OneStepper(withSingleStep: AppStep.homeIsRequired)
      ),
      .contribute(
        withNextPresentable: reminderFlow,
        withNextStepper: OneStepper(withSingleStep: AppStep.reminderIsRequired)
      ),
      .contribute(
        withNextPresentable: myPageFlow,
        withNextStepper: OneStepper(withSingleStep: AppStep.myPageIsRequired)
      )
    ])
  }
  
  func createTabNavController(of page: TabBarPage) -> BaseNavigationController {
    let tabNavController = BaseNavigationController()
    tabNavController.tabBarItem = page.tabBarItem
    tabNavController.title = page.tabBarItem.title
    return tabNavController
  }
}
