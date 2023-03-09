//
//  UIFont+.swift
//  Favor
//
//  Created by 김응철 on 2023/01/15.
//

import UIKit

public func registerFonts() {
  let fonts = [
    "Pretendard-Bold.otf",
    "Pretendard-Regular.otf"
  ]

  fonts.forEach {
    UIFont.registerFont(bundle: Bundle.module, fontName: $0)
  }
}

extension UIFont {
  
  public enum FavorFont: String {
    case bold = "Pretendard-Bold"
    case regular = "Pretendard-Regular"
  }
  
  /// 폰트를 적용하는 전역 메서드 입니다.
  ///
  /// ```
  /// 사용하는 쪽
  ///
  /// label.font = .favorFont(.bold, 16)
  public static func favorFont(_ font: FavorFont, size: CGFloat) -> UIFont {
    let favorFont = UIFont(name: font.rawValue, size: size)!
    return favorFont
  }

  static func registerFont(bundle: Bundle, fontName: String) {
    guard
      let fontURL = bundle.url(forResource: fontName, withExtension: nil),
      let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
      let font = CGFont(fontDataProvider)
    else {
      print("Couldn't find font \(fontName)")
      return
    }

    var error: Unmanaged<CFError>?
    let success = CTFontManagerRegisterGraphicsFont(font, &error)
  }
}
