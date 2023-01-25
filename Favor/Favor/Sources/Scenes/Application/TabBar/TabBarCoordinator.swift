//
//  TabBarCoordinator.swift
//  Favor
//
//  Created by 이창준 on 2022/12/31.
//

import UIKit

final class TabBarCoordinator: BaseCoordinator {
  
  // MARK: - Properties
  
  var tabBarController: FavorTabBarController
  
  // MARK: - Initializer
  
  override init(_ navigationController: UINavigationController) {
    self.tabBarController = FavorTabBarController()
    super.init(navigationController)
  }
  
  // MARK: - Functions
  
  func currentPage() -> TabBarPage? {
    TabBarPage(rawValue: self.tabBarController.selectedIndex)
  }
  
  func selectPage(_ page: TabBarPage) {
    self.tabBarController.selectedIndex = page.rawValue
  }
  
  func setSelectedIndex(_ index: Int) {
    guard let page = TabBarPage(rawValue: index) else { return }
    self.tabBarController.selectedIndex = page.rawValue
  }
  
  override func start() {
    let pages: [TabBarPage] = TabBarPage.allCases
    let viewControllers: [UINavigationController] = pages.map {
      self.createTabNavController(of: $0)
    }
    self.setupTabBarController(with: viewControllers)
  }
  
}

// MARK: - Privates

private extension TabBarCoordinator {
  
  func createTabNavController(of page: TabBarPage) -> UINavigationController {
    let tabNavController = BaseNavigationController()
    
    tabNavController.tabBarItem = page.tabBarItem
    self.showTabCoordinator(of: page, to: tabNavController)
    return tabNavController
  }
  
  func setupTabBarController(with viewControllers: [UIViewController]) {
    self.tabBarController.setViewControllers(viewControllers, animated: true)
    
    self.navigationController.pushViewController(self.tabBarController, animated: true)
  }
  
  func showTabCoordinator(of page: TabBarPage, to tabNavController: UINavigationController) {
    switch page {
    case .home:
      self.showHomeFlow(to: tabNavController)
    case .reminder:
      self.showReminderFlow(to: tabNavController)
    case .myPage:
      self.showMyPageFlow(to: tabNavController)
    }
  }
  
  func showHomeFlow(to tabNavController: UINavigationController) {
    let homeCoordinator = HomeCoordinator(tabNavController)
    self.start(childCoordinator: homeCoordinator)
  }
  
  func showReminderFlow(to tabNavController: UINavigationController) {
    let reminderCoordinator = ReminderCoordinator(tabNavController)
    self.start(childCoordinator: reminderCoordinator)
  }
  
  func showMyPageFlow(to tabNavController: UINavigationController) {
    let myPageCoordinator = MyPageCoordinator(tabNavController)
    self.start(childCoordinator: myPageCoordinator)
  }
  
}
