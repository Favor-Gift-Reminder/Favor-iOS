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
}

extension UIColor {
  
  enum FavorColor {
    case white
    case black
    case main
    case sub
    case error
    case background
    case box1
    case box2
    case detail
    case typo
  }
  
  static func favorColor(_ favorColor: FavorColor) -> UIColor {
    switch favorColor {
    case .white:
      return UIColor("#FFFFFF")
    case .black:
      return UIColor("#000000")
    case .main:
      return UIColor("#FF5862")
    case .sub:
      return UIColor("#0C1338")
    case .error:
      return UIColor("#2DB399")
    case .background:
      return UIColor("#F5F5F5")
    case .box1:
      return UIColor("#E0E0E0")
    case .box2:
      return UIColor("#BDBDBD")
    case .detail:
      return UIColor("#9E9E9E")
    case .typo:
      return UIColor("#424242")
    }
  }
}
