//
//  TabBarController.swift
//  Favor
//
//  Created by 이창준 on 2023/01/25.
//

import UIKit

final class FavorTabBarController: UITabBarController {

  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()

    self.setupTabBar()
  }

}

// MARK: - Privates

private extension FavorTabBarController {
  
  func setupTabBar() {
    self.tabBar.tintColor = .favorColor(.typo)
    self.tabBar.backgroundColor = .favorColor(.white)
    
    self.tabBar.layer.cornerRadius = 24
    self.tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
  }
  
}
