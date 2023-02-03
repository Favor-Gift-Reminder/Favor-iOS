//
//  TabBarFlow.swift
//  Favor
//
//  Created by 김응철 on 2023/02/02.
//

import UIKit

import RxFlow

final class TabBarFlow: Flow {
  
  var root: Presentable { self.rootViewController }
  
  let rootViewController = FavorTabBarController()
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .dashBoardIsRequired:
      return self.navigationToDashBoard()
    default:
      return .none
    }
  }
}

private extension TabBarFlow {
  func navigationToDashBoard() -> FlowContributors {
    let pages = TabBarPage.allCases
    let viewControllers = pages.map {
      self.createTabNavController(of: $0)
    }
    let dashBoardViewController = FavorTabBarController()
    
    return .none
  }
  
  func createTabNavController(of page: TabBarPage) -> UINavigationController {
    let tabNavController = UINavigationController()
    tabNavController.tabBarItem = page.tabBarItem
    return tabNavController
  }
}
