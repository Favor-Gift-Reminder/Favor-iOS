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
  public func toBarButtonItem() -> UIBarButtonItem {
    return UIBarButtonItem(customView: self)
  }

  /// Button들은 최소 44 x 44의 터치 영역을 가져야합니다. 버튼의 크기가 44보다 낮을 경우 44까지 그 범위를 확대시킵니다.
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
