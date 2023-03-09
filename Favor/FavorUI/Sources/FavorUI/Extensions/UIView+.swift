//
//  UIView+.swift
//  Favor
//
//  Created by 이창준 on 2023/02/17.
//

import UIKit

extension UIView {
  public func round(corners: UIRectCorner, radius: CGFloat) {
    _ = self._round(corners: corners, radius: radius)
  }
}

private extension UIView {
  @discardableResult
  func _round(corners: UIRectCorner, radius: CGFloat) -> CAShapeLayer {
    let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: .init(width: radius, height: radius))
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    self.layer.mask = mask
    return mask
  }
}
