//
//  FavorStyle.swift
//  Favor
//
//  Created by 이창준 on 2023/01/06.
//

import UIKit

enum FavorStyle {
  
  enum Color {
    case white, black
    case main, sub, error
    case background, box1, box2, detail, typo
    
    var value: UIColor {
      switch self {
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
  
  // TODO: - 각 폰트 scale/weight 따라 이름 짓기.
  enum Font {
    
  }
}
