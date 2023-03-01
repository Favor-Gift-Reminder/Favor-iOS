//
//  UIScrollView+.swift
//  Favor
//
//  Created by 이창준 on 2023/03/01.
//

import UIKit

extension UIScrollView {
  func scroll(to offsetY: CGFloat) {
    self.setContentOffset(CGPoint(x: .zero, y: offsetY), animated: true)
  }
}
