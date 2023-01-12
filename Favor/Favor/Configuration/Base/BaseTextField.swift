//
//  BaseTextField.swift
//  Favor
//
//  Created by 이창준 on 2023/01/12.
//

import UIKit

final class BaseTextField: UITextField {
  
  // MARK: - Constants
  
  // MARK: - Properties
  
  var isValid: Bool = true {
    willSet {
      if newValue == true {
        self.layer.borderColor = FavorStyle.Color.detail.value.cgColor
      } else {
        self.layer.borderColor = FavorStyle.Color.error.value.cgColor
      }
    }
  }
  
  // MARK: - Initializer
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  func setupStyles() {
    self.autocorrectionType = .no
    self.enablesReturnKeyAutomatically = true
    self.layer.borderWidth = 1.0
    self.layer.borderColor = UIColor.clear.cgColor
    self.borderStyle = .roundedRect
  }
  
}
