//
//  LargeFavorButtonType.swift
//  Favor
//
//  Created by 김응철 on 2023/02/16.
//

import UIKit

enum LargeFavorButtonType {
  case main(String)
  case main2(String)
  case dark1(String)
  case dark2(String)
  case gray(String)
  
  var configuration: UIButton.Configuration {
    var config = UIButton.Configuration.filled()
    let titleString: String
    config.background.cornerRadius = 64
    switch self {
    case .main(let title):
      config.baseBackgroundColor = .favorColor(.main)
      config.baseForegroundColor = .favorColor(.white)
      titleString = title
    case .main2(let title):
      config.baseBackgroundColor = .favorColor(.button)
      config.baseForegroundColor = .favorColor(.main)
      titleString = title
    case .dark1(let title):
      config.baseBackgroundColor = .favorColor(.titleAndLine)
      config.baseForegroundColor = .favorColor(.white)
      titleString = title
    case .dark2(let title):
      config.baseBackgroundColor = .favorColor(.button)
      config.baseForegroundColor = .favorColor(.subtext)
      titleString = title
    case .gray(let title):
      config.baseBackgroundColor = .favorColor(.divider)
      config.baseForegroundColor = .favorColor(.explain)
      titleString = title
    }
    var container = AttributeContainer()
    container.font = .favorFont(.bold, size: 18)
    config.attributedTitle = AttributedString(
      titleString,
      attributes: container
    )
    
    return config
  }
}
