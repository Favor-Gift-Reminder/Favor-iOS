//
//  SmallFavorButtonType.swift
//  Favor
//
//  Created by 김응철 on 2023/02/16.
//

import UIKit

public enum FavorSmallButtonType {
  case mainWithIcon(String, image: UIImage?)
  case main(String)
  case darkWithIcon(String, image: UIImage?)
  case darkWithHashTag(String)
  case gray(String)
  case grayWithUser(String)
  // TODO: 이모지 열거형 연관괎으로 추가하기
  case grayWithEmoji
  
  public var configuration: UIButton.Configuration {
    var config = UIButton.Configuration.filled()
    let titleString: String
    config.background.cornerRadius = 32
    config.imagePlacement = .leading
    config.imagePadding = 6
    config.contentInsets = NSDirectionalEdgeInsets(
      top: 8,
      leading: 16,
      bottom: 8,
      trailing: 16
    )
    
    switch self {
    case let .mainWithIcon(title, image):
      titleString = title
      config.baseBackgroundColor = .favorColor(.main)
      config.baseForegroundColor = .favorColor(.white)
      config.image = image
    case .main(let title):
      titleString = title
      config.baseBackgroundColor = .favorColor(.button)
      config.baseForegroundColor = .favorColor(.main)
    case let .darkWithIcon(title, image):
      titleString = title
      config.baseBackgroundColor = .favorColor(.titleAndLine)
      config.baseForegroundColor = .favorColor(.white)
      config.image = image
    case .darkWithHashTag(let title):
      titleString = title
      config.baseBackgroundColor = .favorColor(.icon)
      config.baseForegroundColor = .favorColor(.white)
      config.image = .favorIcon(.hashtag)
    case .gray(let title):
      titleString = title
      config.baseBackgroundColor = .favorColor(.button)
      config.baseForegroundColor = .favorColor(.subtext)
    case .grayWithUser(let userName):
      titleString = userName
      config.baseBackgroundColor = .favorColor(.button)
      config.baseForegroundColor = .favorColor(.titleAndLine)
      config.image = .favorIcon(.friend)
    case .grayWithEmoji:
      titleString = ""
      config.baseBackgroundColor = .favorColor(.button)
    }
    
    var container = AttributeContainer()
    container.font = .favorFont(
      .bold,
      size: 12
    )
    config.attributedTitle = AttributedString(
      titleString,
      attributes: container
    )
    
    return config
  }
}
