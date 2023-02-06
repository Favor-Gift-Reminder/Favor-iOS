//
//  PlainFavorButton.swift
//  Favor
//
//  Created by 김응철 on 2023/01/20.
//

import UIKit

final class PlainFavorButton: UIButton {
  
  enum Icon {
    case right
    case bottom
  }
  
  enum Style {
    case main
    case onboarding
    case viewMore
  }
  
  // MARK: - Initializer
  
  init(_ style: Style, title: String, icon: Icon = .right) {
    super.init(frame: .zero)
    setupConfiguration(style, icon: icon, title: title)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  private func setupConfiguration(
    _ style: Style,
    icon: Icon,
    title: String
  ) {
    var config = UIButton.Configuration.plain()
    
    var titleContainer = AttributeContainer()
    titleContainer.foregroundColor = .favorColor(.explain)
    
    switch style {
    case .main:
      titleContainer.font = .favorFont(.regular, size: 16)
      config.imagePadding = 4
      
      switch icon {
      case .bottom:
        config.image = UIImage(named: "ic_bottomArrow")

      case .right:
        config.image = UIImage(named: "ic_rightArrow")
      }
      
    case .onboarding:
      titleContainer.font = .favorFont(.regular, size: 14)
      config.image = UIImage(named: "ic_rightArrow")
      config.imagePadding = 8
      
    case .viewMore:
      titleContainer.font = .favorFont(.regular, size: 12)
    }
    
    config.attributedTitle = AttributedString(title, attributes: titleContainer)
    config.imagePlacement = .trailing
    
    self.configuration = config
  }
}
