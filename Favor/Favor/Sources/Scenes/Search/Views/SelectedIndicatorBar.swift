//
//  SelectedIndicatorBar.swift
//  Favor
//
//  Created by 이창준 on 2023/04/13.
//

import UIKit

final class SelectedIndicatorBar: UIView {

  // MARK: - Draw

  override func draw(_ rect: CGRect) {
    let layer = CAShapeLayer()

    let path = UIBezierPath()
    path.move(to: CGPoint(x: .zero, y: rect.height))
    path.addArc(
      withCenter: CGPoint(x: rect.height, y: rect.height),
      radius: rect.height,
      startAngle: (180 * .pi) / 180,
      endAngle: (270 * .pi) / 180,
      clockwise: true
    )
    path.addLine(to: CGPoint(x: rect.width - rect.height, y: .zero))
    path.addArc(
      withCenter: CGPoint(x: rect.width - rect.height, y: rect.height),
      radius: rect.height,
      startAngle: (270 * .pi) / 180,
      endAngle: .zero,
      clockwise: true
    )
    path.addLine(to: CGPoint(x: .zero, y: rect.height))
    path.close()
    layer.path = path.cgPath

    layer.fillColor = UIColor.favorColor(.icon).cgColor
    self.layer.addSublayer(layer)
  }
}
