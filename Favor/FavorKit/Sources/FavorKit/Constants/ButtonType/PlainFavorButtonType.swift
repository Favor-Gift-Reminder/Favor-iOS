//
//  PlainFavorButtonType.swift
//  Favor
//
//  Created by 김응철 on 2023/02/16.
//

import UIKit

public enum PlainFavorButtonType {
  case logIn(String)
  case more(String)
  case main(String, isRight: Bool)
  
  public var configuration: UIButton.Configuration {
    var config = UIButton.Configuration.plain()
    var titleContainer = AttributeContainer()
    let titleString: String
    config.imagePadding = 8
    config.imagePlacement = .trailing
    config.baseForegroundColor = .favorColor(.subtext)
    
    switch self {
    case .logIn(let title):
      titleString = title
      config.image = .favorIcon(.right)
      titleContainer.font = .favorFont(.regular, size: 16)
    case .more(let title):
      titleString = title
      titleContainer.font = .favorFont(.regular, size: 12)
    case let .main(title, isRight):
      titleString = title
      config.image = isRight ? .favorIcon(.right) : .favorIcon(.down)
      titleContainer.font = .favorFont(.regular, size: 14)
    }
    
    config.attributedTitle = AttributedString(
      titleString,
      attributes: titleContainer
    )
    
    return config
  }
}
