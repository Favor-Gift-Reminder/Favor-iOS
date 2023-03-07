//
//  UIButton+.swift
//  Favor
//
//  Created by 이창준 on 2023/03/06.
//

import UIKit

import RxCocoa
import RxSwift

extension Reactive where Base: UIButton {
  public var tap: ControlEvent<Void> {
    HapticManager.haptic(style: .soft)
    return controlEvent(.touchUpInside)
  }
}
