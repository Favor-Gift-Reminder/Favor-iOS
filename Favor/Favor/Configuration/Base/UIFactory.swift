//
//  UIFactory.swift
//  Favor
//
//  Created by 이창준 on 2023/01/12.
//

import UIKit

final class UIFactory {
  
  /// Pre-configured된 UIButton.Configuration에 따라 UIButton을 생성합니다.
  /// - Parameters:
  ///     - style: 버튼의 스타일 (large, small)
  ///     - title: 버튼의 텍스트
  ///     - image: 버튼의 이미지(아이콘)
  static func favorButton(
    with style: UIButton.Configuration.FavorButton,
    title: String,
    image: UIImage? = nil
  ) -> UIButton {
    // Base
    var configuration: UIButton.Configuration
    switch style {
    case .small, .large:
      configuration = .filled()
    case .plain:
      configuration = .plain()
    }
    // Title
    var titleAttr = AttributedString.init(title)
    titleAttr.font = style.font
    configuration.attributedTitle = titleAttr
    configuration.titleAlignment = .center
    // Image
    configuration.image = image
    configuration.imagePlacement = .leading
    configuration.imagePadding = 8
    // Layer
    configuration.background.cornerRadius = style.cornerRadius
    // Layout
    configuration.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 14, bottom: 14, trailing: 14)
    // Color
    configuration.baseBackgroundColor = style.backgroundColor
    configuration.baseForegroundColor = style.foregroundColor
    
    let button = UIButton(configuration: configuration)
    button.configurationUpdateHandler = UIFactory.favorButtonUpdateHandler()
    
    return button
  }
  
  /// UIButton의 state에 따라 배경색과 텍스트 색을 바꾸는 `UpdateHandler`를 생성하여 반환합니다.
  static func favorButtonUpdateHandler() -> UIButton.ConfigurationUpdateHandler {
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      switch button.state {
      case .normal:
        button.configuration?.baseForegroundColor = FavorStyle.Color.white.value
        button.configuration?.baseBackgroundColor = FavorStyle.Color.typo.value
      case .disabled:
        button.configuration?.baseForegroundColor = FavorStyle.Color.typo.value
        button.configuration?.baseBackgroundColor = FavorStyle.Color.box1.value
      default:
        break
      }
    }
    return handler
  }
  
}
