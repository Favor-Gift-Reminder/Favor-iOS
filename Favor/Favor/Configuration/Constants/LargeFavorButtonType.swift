//
//  LargeFavorButtonType.swift
//  Favor
//
//  Created by 김응철 on 2023/02/16.
//

import UIKit

enum LargeFavorButtonType {
  case main
  case main2
  case dark1
  case dark2
  case gray
  
  var configuration: UIButton.Configuration {
    var config = UIButton.Configuration.filled()
    config.background.cornerRadius = 64
    switch self {
    case .main:
      config.baseBackgroundColor = .favorColor(.main)
      config.baseForegroundColor = .favorColor(.white)
    case .main2:
      config.baseBackgroundColor = .favorColor(.button)
      config.baseForegroundColor = .favorColor(.main)
    case .dark1:
      config.baseBackgroundColor = .favorColor(.titleAndLine)
      config.baseForegroundColor = .favorColor(.white)
    case .dark2:
      config.baseBackgroundColor = .favorColor(.button)
      config.baseForegroundColor = .favorColor(.subtext)
    case .gray:
      config.baseBackgroundColor = .favorColor(.divider)
      config.baseForegroundColor = .favorColor(.explain)
    }
    
    return config
  }
}
