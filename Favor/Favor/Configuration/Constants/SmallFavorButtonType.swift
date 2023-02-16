//
//  SmallFavorButtonType.swift
//  Favor
//
//  Created by 김응철 on 2023/02/16.
//

import UIKit

enum SmallFavorButtonType {
  case main(title: String)
  case main2(title: String)
  case dark1(title: String)
  case dark_like(title: String)
  case gray(title: String)
  case gray_user(userName: String)
  // TODO: 이모지 열거형 연관괎으로 추가하기
  case gray_emoji
  
  var configuration: UIButton.Configuration {
    var config = UIButton.Configuration.filled()
    var container = AttributeContainer()
    container.font = .favorFont(.bold, size: 12)
    config.background.cornerRadius = 32
    config.imagePlacement = .leading
    config.imagePadding = 6
    config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
    switch self {
    case .main(let title):
      config.attributedTitle = AttributedString(title, attributes: container)
      config.baseBackgroundColor = .favorColor(.main)
      config.baseForegroundColor = .favorColor(.white)
      config.image = UIImage(named: "ic_add")?.withRenderingMode(.alwaysTemplate)
    case .main2(let title):
      config.attributedTitle = AttributedString(title, attributes: container)
      config.baseBackgroundColor = .favorColor(.button)
      config.baseForegroundColor = .favorColor(.main)
    case .dark1(let title):
      config.attributedTitle = AttributedString(title, attributes: container)
      config.baseBackgroundColor = .favorColor(.titleAndLine)
      config.baseForegroundColor = .favorColor(.white)
      config.image = UIImage(named: "ic_add")?.withRenderingMode(.alwaysTemplate)
    case .dark_like(let title):
      config.attributedTitle = AttributedString(title, attributes: container)
      config.baseBackgroundColor = .favorColor(.icon)
      config.baseForegroundColor = .favorColor(.white)
      config.image = UIImage(named: "ic_like")?.withTintColor(.favorColor(.white))
    case .gray(let title):
      config.attributedTitle = AttributedString(title, attributes: container)
      config.baseBackgroundColor = .favorColor(.button)
      config.baseForegroundColor = .favorColor(.subtext)
    case .gray_user(let userName):
      config.attributedTitle = AttributedString(userName, attributes: container)
      config.baseBackgroundColor = .favorColor(.button)
      config.baseForegroundColor = .favorColor(.titleAndLine)
      config.image = UIImage(named: "ic_user")?.withTintColor(.favorColor(.white))
    case .gray_emoji:
      config.baseBackgroundColor = .favorColor(.button)
    }
    let newSize = CGSize(width: 12, height: 12)
    UIGraphicsBeginImageContext(newSize)
    config.image?.draw(in: CGRect(x: 0, y: 0, width: 12, height: 12))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    config.image = newImage
    UIGraphicsEndImageContext()
    
    return config
  }
}
