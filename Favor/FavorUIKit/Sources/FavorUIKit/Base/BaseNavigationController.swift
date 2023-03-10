//
//  BaseNavigationController.swift
//  
//
//  Created by 이창준 on 2023/03/10.
//

import UIKit

open class BaseNavigationController: UINavigationController {

  open override func viewDidLoad() {
    super.viewDidLoad()

    self.setupNavigationAppearance()
  }

  func setupNavigationAppearance() {
    // Button Appearance
    let backButtonAppearance = UIBarButtonItemAppearance()

    let leftArrowImage = UIImage(named: "ic_Left")?
      .withRenderingMode(.alwaysOriginal)
      .withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -12, bottom: 0, right: 0))

    // 뒤로가기 버튼 타이틀 숨김
    backButtonAppearance.normal.titleTextAttributes = [
      .foregroundColor: UIColor.clear
    ]

    // Bar Appearance
    let appearance = UINavigationBarAppearance()
    appearance.configureWithTransparentBackground()
    appearance.backgroundColor = .clear
    appearance.shadowColor = .clear
    appearance.backButtonAppearance = backButtonAppearance
    appearance.setBackIndicatorImage(leftArrowImage, transitionMaskImage: leftArrowImage)

    // Set Appearance
    navigationBar.compactAppearance = appearance
    navigationBar.standardAppearance = appearance
    navigationBar.scrollEdgeAppearance = appearance

    navigationBar.tintColor = UIColor.favorColor(.icon)
    navigationBar.titleTextAttributes = [
      .foregroundColor: UIColor.favorColor(.icon),
      .font: UIFont.favorFont(.bold, size: 18)
    ]
    navigationItem.backButtonDisplayMode = .minimal
  }
}
