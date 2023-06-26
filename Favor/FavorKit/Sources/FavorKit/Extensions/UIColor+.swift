//
//  UIColor+.swift
//  Favor
//
//  Created by 이창준 on 2023/01/06.
//

import UIKit

extension UIColor {
  convenience init(_ hex: String) {
    let scanner = Scanner(string: hex)
    _ = scanner.scanString("#")
    
    var rgb: UInt64 = 0
    scanner.scanHexInt64(&rgb)
    
    let r = Double((rgb >> 16) & 0xFF) / 255
    let g = Double((rgb >>  8) & 0xFF) / 255
    let b = Double((rgb >>  0) & 0xFF) / 255
    self.init(red: r, green: g, blue: b, alpha: 1.0)
  }
  
  public enum FavorColor: String {
    case white = "#FFFFFF"
    case black = "#000000"
    case main = "#FF5862"
    case sub = "#141E54"
    case button = "#F8F8F8"
    case card = "#FAFAFA"
    case background = "#F5F5F5"
    case divider = "#EEEEEE"
    case line3 = "#E0E0E0"
    case line2 = "#BDBDBD"
    case explain = "#9E9E9E"
    case subtext = "#616161"
    case titleAndLine = "#424242"
    case icon = "#222222"
    case nav = "#FFE4E5"

    case kakao = "#FEE500"
    case naver = "#03C75A"
    case apple = "#000001"
  }
  
  /// 색상을 적용하는 전역 메서드 입니다.
  ///
  /// ```
  /// 사용하는 쪽
  ///
  /// label.textColor = .favorColor(.main)
  public static func favorColor(_ color: FavorColor) -> UIColor {
    let favorColor = UIColor(color.rawValue)
    return favorColor
  }
}
