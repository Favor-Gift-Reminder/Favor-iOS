//
//  UITextField+.swift
//  Favor
//
//  Created by 이창준 on 2023/05/18.
//

import UIKit

extension UITextField {
  public func updateAttributedPlaceholder(_ text: String, font: UIFont) {
    var container = AttributeContainer()
//    container.foregroundColor = self.placeholderColor
    container.font = font
    self.attributedPlaceholder = NSAttributedString(AttributedString(text, attributes: container))
  }
}
