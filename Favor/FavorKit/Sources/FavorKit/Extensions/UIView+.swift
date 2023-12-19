//
//  UIView+.swift
//  Favor
//
//  Created by 이창준 on 2023/02/17.
//

import UIKit

extension UIView {
  public func round(corners: UIRectCorner, radius: CGFloat) {
    let path = UIBezierPath(
      roundedRect: self.bounds,
      byRoundingCorners: corners,
      cornerRadii: .init(width: radius, height: radius)
    )
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    self.layer.mask = mask
  }
  
  public func toImage(_ topInset: CGFloat = 0) -> UIImage {
    let renderer = UIGraphicsImageRenderer(bounds: self.bounds.inset(by: .init(top: -topInset, left: 0, bottom: 0, right: 0)))
    return renderer.image { rendererContext in
      layer.render(in: rendererContext.cgContext)
      layer.backgroundColor = UIColor.black.cgColor
    }
  }
}
