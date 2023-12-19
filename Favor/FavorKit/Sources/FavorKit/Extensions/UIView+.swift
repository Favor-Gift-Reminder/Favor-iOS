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
  
  public func toImage() -> UIImage {
    let renderer = UIGraphicsImageRenderer(bounds: self.bounds)
    return renderer.image { rendererContext in
      layer.render(in: rendererContext.cgContext)
      layer.backgroundColor = UIColor.clear.cgColor
    }
  }
}
