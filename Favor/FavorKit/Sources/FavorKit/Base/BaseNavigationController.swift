//
//  BaseNavigationController.swift
//  
//
//  Created by 이창준 on 2023/03/10.
//

import UIKit

open class BaseNavigationController: UINavigationController {

  // MARK: - Life Cycle

  open override func viewDidLoad() {
    super.viewDidLoad()

    self.setupNavigationAppearance()
  }

  open override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    if let interactivePopGestureRecognizer = self.interactivePopGestureRecognizer {
      interactivePopGestureRecognizer.isEnabled = true
      interactivePopGestureRecognizer.delegate = self
    }
  }

  // MARK: - Functions

  func setupNavigationAppearance() {
    // Button Appearance
    let backButtonAppearance = UIBarButtonItemAppearance()

    let leftArrowImage: UIImage? = .favorIcon(.left)!
      .withRenderingMode(.alwaysOriginal)
      .withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -12, bottom: 0, right: 0))

    // 뒤로가기 버튼 타이틀 숨김
    backButtonAppearance.normal.titleTextAttributes = [
      .foregroundColor: UIColor.clear
    ]

    // Bar Appearance
    let appearance = UINavigationBarAppearance()
    appearance.configureWithTransparentBackground()
    appearance.backgroundColor = .favorColor(.white)
    appearance.shadowColor = .favorColor(.white)
    appearance.backButtonAppearance = backButtonAppearance
    appearance.setBackIndicatorImage(leftArrowImage, transitionMaskImage: leftArrowImage)

    // Set Appearance
    self.navigationBar.compactAppearance = appearance
    self.navigationBar.standardAppearance = appearance
    self.navigationBar.scrollEdgeAppearance = appearance

    self.navigationBar.tintColor = UIColor.favorColor(.icon)
    self.navigationBar.titleTextAttributes = [
      .foregroundColor: UIColor.favorColor(.icon),
      .font: UIFont.favorFont(.bold, size: 18)
    ]
    navigationItem.backButtonDisplayMode = .minimal
  }
}

// MARK: - Recognizer

extension BaseNavigationController: UIGestureRecognizerDelegate {
  public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return self.viewControllers.count > 1
  }
}
