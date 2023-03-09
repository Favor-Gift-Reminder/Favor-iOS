//
//  HapticManager.swift
//  Favor
//
//  Created by 이창준 on 2023/03/06.
//

import UIKit

public final class HapticManager {
  /// 햅틱 진동을 발생시킵니다.
  /// `.heavy`, `.light`, `.medium`, `.rigid`, `.soft`
  static func haptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.impactOccurred()
  }
}
