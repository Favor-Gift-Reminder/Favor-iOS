//
//  UIButton+.swift
//  Favor
//
//  Created by 이창준 on 2023/03/06.
//

import UIKit

import RxCocoa
import RxSwift

public extension Reactive where Base: UIButton {
  var tapWithHaptic: ControlEvent<Void> {
    HapticManager.haptic(style: .soft)
    return controlEvent(.touchUpInside)
  }
}
