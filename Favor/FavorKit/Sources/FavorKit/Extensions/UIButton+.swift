//
//  UIButton+.swift
//  Favor
//
//  Created by 이창준 on 2023/03/06.
//

import UIKit

import RxCocoa
import RxSwift

extension UIButton.Configuration {

  public mutating func updateAttributedTitle(_ text: String, font: UIFont) {
    var container = AttributeContainer()
    container.font = font
    self.attributedTitle = AttributedString(
      text,
      attributes: container
    )
  }
}

public extension Reactive where Base: UIButton {
  var tapWithHaptic: ControlEvent<Void> {
    HapticManager.haptic(style: .soft)
    return controlEvent(.touchUpInside)
  }
}
