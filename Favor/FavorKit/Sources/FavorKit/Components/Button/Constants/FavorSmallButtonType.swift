//
//  SmallFavorButtonType.swift
//  Favor
//
//  Created by 김응철 on 2023/02/16.
//

import UIKit

public enum FavorSmallButtonType {
  case main(String, image: UIImage?)
  case dark(String, image: UIImage?)
  case gray(String)
  case grayWithGift(String)
  case grayWithUser(String, image: UIImage?)
  case grayWithEmotion(UIImage?)
  case hashtag(String)
  
  public var configuration: UIButton.Configuration {
    var config = UIButton.Configuration.filled()
    let titleString: String
    var font: UIFont = .favorFont(.bold, size: 12)
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
    case let .main(title, image):
      titleString = title
      config.image = image
      config.baseBackgroundColor = .favorColor(.button)
      config.baseForegroundColor = .favorColor(.main)
    case let .dark(title, image):
      titleString = title
      config.baseBackgroundColor = .favorColor(.titleAndLine)
      config.baseForegroundColor = .favorColor(.white)
      config.image = image
    case .gray(let title):
      titleString = title
      config.baseBackgroundColor = .favorColor(.button)
      config.baseForegroundColor = .favorColor(.subtext)
    case let .grayWithGift(title):
      titleString = title
      font = .favorFont(.regular, size: 12)
      config.baseBackgroundColor = .favorColor(.card)
    case let .grayWithUser(userName, userProfileImage):
      titleString = userName
      font = .favorFont(.regular, size: 12)
      config.image = userProfileImage
      config.baseBackgroundColor = .favorColor(.card)
      config.baseForegroundColor = .favorColor(.titleAndLine)
    case let .grayWithEmotion(emotion):
      titleString = ""
      config.image = emotion
      config.baseBackgroundColor = .favorColor(.button)
    case let .hashtag(favor):
      titleString = favor
      config.image = .favorIcon(.hashtag)?
        .withRenderingMode(.alwaysTemplate)
        .resize(newWidth: 16)
      config.imagePadding = 2
      config.baseBackgroundColor = .favorColor(.button)
      config.baseForegroundColor = .favorColor(.icon)
    }
    
    var container = AttributeContainer()
    container.font = font
    config.attributedTitle = AttributedString(titleString, attributes: container)
    
    return config
  }
}
