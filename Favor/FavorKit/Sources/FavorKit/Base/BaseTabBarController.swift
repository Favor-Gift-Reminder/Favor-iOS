//
//  BaseTabBarController.swift
//  
//
//  Created by 이창준 on 2023/03/10.
//

import UIKit

open class BaseTabBarController: UITabBarController {

  open override func viewDidLoad() {
    super.viewDidLoad()

    self.setupTabBarAppearance()
  }

  func setupTabBarAppearance() {
    // Item Appearance
    let itemApperance = UITabBarItemAppearance()

    // Unselected Appearance
    itemApperance.normal.iconColor = .favorColor(.line2)
    itemApperance.normal.titleTextAttributes = [
      NSAttributedString.Key.foregroundColor: UIColor.favorColor(.line2),
      NSAttributedString.Key.font: UIFont.favorFont(.regular, size: 12)
    ]

    // Selected Appearance
    itemApperance.selected.iconColor = .favorColor(.icon)
    itemApperance.selected.titleTextAttributes = [
      NSAttributedString.Key.foregroundColor: UIColor.favorColor(.icon),
      NSAttributedString.Key.font: UIFont.favorFont(.regular, size: 12)
    ]

    // TabBar Appearance
    let appearance = UITabBarAppearance()

    appearance.configureWithDefaultBackground()
    appearance.backgroundColor = .favorColor(.white)
    appearance.shadowColor = .clear

    appearance.compactInlineLayoutAppearance = itemApperance
    appearance.stackedLayoutAppearance = itemApperance
    appearance.inlineLayoutAppearance = itemApperance

    self.tabBar.standardAppearance = appearance
    self.tabBar.scrollEdgeAppearance = appearance

    self.tabBar.layer.cornerRadius = 24
    self.tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    self.tabBar.clipsToBounds = true
  }
}
