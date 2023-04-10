//
//  FavorTabBarController.swift
//  Favor
//
//  Created by 이창준 on 2023/03/10.
//

import UIKit

import FavorKit
import RxCocoa
import RxFlow

final class FavorTabBarController: UITabBarController, Stepper {

  // MARK: - Properties

  var steps = PublishRelay<Step>()

  // MARK: - Life Cycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.delegate = self
    self.setupTabBarAppearance()
  }

  // MARK: - Functions

  private func setupTabBarAppearance() {
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

    self.tabBar.layer.borderWidth = 0.5
    self.tabBar.layer.borderColor = UIColor.favorColor(.line3).cgColor
  }
}

extension FavorTabBarController: UITabBarControllerDelegate {
  override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    HapticManager.haptic(style: .soft)
  }

  func tabBarController(
    _ tabBarController: UITabBarController,
    shouldSelect viewController: UIViewController
  ) -> Bool {
    guard let navController = viewController as? BaseNavigationController else { return true }
    if !navController.isValid {
      self.steps.accept(AppStep.newGiftIsRequired)
      return false
    }
    return true
  }
}
