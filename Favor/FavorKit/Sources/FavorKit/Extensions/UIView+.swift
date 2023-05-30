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

  public func toImage() -> UIImage {
    let renderer = UIGraphicsImageRenderer(bounds: bounds)
    return renderer.image { rendererContext in
      layer.render(in: rendererContext.cgContext)
    }
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
