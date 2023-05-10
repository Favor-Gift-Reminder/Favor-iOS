//
//  FavorTouchThroughView.swift
//  Favor
//
//  Created by 이창준 on 2023/04/25.
//

import UIKit

open class FavorTouchThroughView: UIView {
  open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    let hitView = super.hitTest(point, with: event)
    return hitView == self ? nil : hitView
  }
}
