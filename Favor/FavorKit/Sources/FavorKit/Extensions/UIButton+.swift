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
  public mutating func updateAttributedTitle(_ text: String?, font: UIFont) {
    var container = AttributeContainer()
    container.font = font
    self.attributedTitle = AttributedString(
      text ?? "",
      attributes: container
    )
  }
}

extension UIButton {
  open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    let minimumHitSize: CGFloat = 44.0
    let modifyingWidth: CGFloat = {
      self.bounds.width < minimumHitSize ? minimumHitSize - self.bounds.width : 0
    }()
    let modifyingHeight: CGFloat = {
      self.bounds.height < minimumHitSize ? minimumHitSize - self.bounds.height : 0
    }()
    return bounds.insetBy(dx: -modifyingWidth / 2, dy: -modifyingHeight / 2).contains(point)
  }
}

public extension Reactive where Base: UIButton {
  var tapWithHaptic: ControlEvent<Void> {
    HapticManager.haptic(style: .soft)
    return controlEvent(.touchUpInside)
  }
}
