//
//  TabBarController.swift
//  Favor
//
//  Created by 이창준 on 2023/01/25.
//

import UIKit

final class FavorTabBarController: UITabBarController {

  override func viewDidLoad() {
    super.viewDidLoad()

    self.setupTabBar()
  }

}

private extension FavorTabBarController {
  
  func setupTabBar() {
    self.tabBar.tintColor = .favorColor(.typo)
    self.tabBar.backgroundColor = .favorColor(.white)
    
    self.tabBar.layer.cornerRadius = 24
    self.tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
  }
  
}
