//
//  FavorRoundedTopView.swift
//  Favor
//
//  Created by 이창준 on 2023/03/31.
//

import UIKit

/// 회색 배경에 둥근 모서리를 구현하기 쉽도록 만든 View입니다.
public final class FavorRoundedTopView: UIView {

  // MARK: - Draw

  public override func draw(_ rect: CGRect) {
    let layer = CAShapeLayer()

    let path = UIBezierPath()
    path.move(to: .zero)
    path.addLine(to: CGPoint(x: rect.width, y: .zero))
    path.addLine(to: CGPoint(x: rect.width, y: rect.height))
    path.addArc(
      withCenter: CGPoint(x: rect.width - 24, y: rect.height),
      radius: 24,
      startAngle: 0,
      endAngle: (270 * .pi) / 180,
      clockwise: false
    )
    path.addLine(to: CGPoint(x: 24, y: rect.height - 24))
    path.addArc(
      withCenter: CGPoint(x: 24, y: rect.height),
      radius: 24,
      startAngle: (270 * .pi) / 180,
      endAngle: (180 * .pi) / 180,
      clockwise: false
    )
    path.addLine(to: CGPoint(x: .zero, y: rect.height))
    path.close()
    layer.path = path.cgPath

    layer.fillColor = UIColor.favorColor(.background).cgColor
    self.layer.addSublayer(layer)
  }
}
