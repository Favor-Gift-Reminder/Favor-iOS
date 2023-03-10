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
    case .dashBoardIsRequired:
      return self.navigateToDashBoard()
    default:
      return .none
    }
  }
}

private extension TabBarFlow {
  func navigateToDashBoard() -> FlowContributors {

    // let homeFlow
    // let reminderFlow
    // let myPageFlow

//    Flows.use(
//      homeFlow,
//      reminderFlow,
//      myPageFlow,
//      when: .created
//    ) { [weak self] homeFlow, reminderFlow, myPageFlow in
//      let pages = TabBarPage.allCases
//      let navigationControllers = pages.map {
//        self.createTabNavController(of: $0)
//      }
//
//      self.rootViewController.setViewControllers(navigationControllers, animated: false)
//    }
    
//    return .multiple(flowContributors: [
//      .contribute(
//        withNextPresentable: homeFlow,
//        withNextStepper: <#T##Stepper#>
//      ),
//      .contribute(
//        withNextPresentable: reminderFlow,
//        withNextStepper: <#T##Stepper#>
//      ),
//      .contribute(
//        withNextPresentable: myPageFlow,
//        withNextStepper: <#T##Stepper#>
//      )
//    ])
    return .none
  }
  
  func createTabNavController(of page: TabBarPage) -> BaseNavigationController {
    let tabNavController = BaseNavigationController()
    tabNavController.tabBarItem = page.tabBarItem
    tabNavController.title = page.tabBarItem.title
    return tabNavController
  }
}
