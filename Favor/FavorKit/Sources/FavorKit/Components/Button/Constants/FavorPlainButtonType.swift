//
//  PlainFavorButtonType.swift
//  Favor
//
//  Created by 김응철 on 2023/02/16.
//

import UIKit

public enum FavorPlainButtonType {
  case navigate(String, isRight: Bool)
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
    case let .navigate(title, isRight):
      titleString = title
      titleContainer.font = .favorFont(.regular, size: 14)
      config.image = isRight ? .favorIcon(.right)?
        .withRenderingMode(.alwaysTemplate)
        .resize(newWidth: 12)
        .withTintColor(.favorColor(.subtext)) : nil
    case .more(let title):
      titleString = title
      titleContainer.font = .favorFont(.regular, size: 12)
    case let .main(title, isRight):
      titleString = title
      let arrowImage: UIImage? = isRight ? .favorIcon(.right) : .favorIcon(.down)
      config.image = arrowImage?.resize(newWidth: 10)
      titleContainer.font = .favorFont(.regular, size: 16)
    }
    
    config.attributedTitle = AttributedString(
      titleString,
      attributes: titleContainer
    )
    config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
    
    return config
  }
}
