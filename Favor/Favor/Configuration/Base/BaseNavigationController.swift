//
//  BaseNavigationController.swift
//  Favor
//
//  Created by 이창준 on 2023/01/25.
//

import UIKit

class BaseNavigationController: UINavigationController {
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setupNavigationBarAppearance()
  }
  
}

// MARK: - Privates

private extension BaseNavigationController {
  
  func setupNavigationBarAppearance() {
    let appearance = UINavigationBarAppearance()
    let backButtonAppearance = UIBarButtonItemAppearance()
    
    let leftArrowImage = UIImage(named: "ic_leftArrow")?
      .withRenderingMode(.alwaysOriginal)
      .withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0))
    
    backButtonAppearance.normal.titleTextAttributes = [
      .foregroundColor: UIColor.clear
    ]
    
    appearance.setBackIndicatorImage(leftArrowImage, transitionMaskImage: leftArrowImage)
    appearance.backButtonAppearance = backButtonAppearance
    
    appearance.titleTextAttributes = [
      .foregroundColor: UIColor.favorColor(.typo),
      .font: UIFont.favorFont(.bold, size: 18)
    ]
    
    appearance.configureWithTransparentBackground()
    appearance.backgroundColor = .clear
    appearance.shadowColor = nil
        
    self.navigationBar.compactAppearance = appearance
    self.navigationBar.standardAppearance = appearance
    self.navigationBar.scrollEdgeAppearance = appearance
  }
  
}
