//
//  UIFont+.swift
//  Favor
//
//  Created by 김응철 on 2023/01/15.
//

import UIKit

extension UIFont {
  
  enum FavorFont: String {
    case bold = "Pretendard-Bold"
    case regular = "Pretendard-Regular"
  }
  
  /// 폰트를 적용하는 전역 메서드 입니다.
  ///
  /// ```
  /// 사용하는 쪽
  ///
  /// label.font = .favorFont(.bold, 16)
  static func favorFont(_ font: FavorFont, size: CGFloat) -> UIFont {
    let favorFont = UIFont(name: font.rawValue, size: size)!
    return favorFont
  }
}
