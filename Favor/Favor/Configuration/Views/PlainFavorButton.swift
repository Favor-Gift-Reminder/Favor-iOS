//
//  PlainFavorButton.swift
//  Favor
//
//  Created by 김응철 on 2023/01/20.
//

import UIKit

final class PlainFavorButton: UIButton {
  
  enum Style {
    case large
    case small
  }
  
  enum Icon {
    case right
    case bottom
  }
  
  // MARK: - Initializer
  
  init(_ style: Style, icon: Icon, title: String) {
    super.init(frame: .zero)
    setupConfiguration(style, icon: icon, title: title)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  private func setupConfiguration(_ style: Style, icon: Icon, title: String) {
    var config = UIButton.Configuration.plain()
    
    var titleContainer = AttributeContainer()
    titleContainer.foregroundColor = .favorColor(.detail)
    
    switch style {
    case .large:
      titleContainer.font = .favorFont(.regular, size: 14)
      
    case .small:
      titleContainer.font = .favorFont(.regular, size: 12)
    }
    
    switch icon {
    case .bottom:
      config.image = UIImage(named: "ic_bottomArrow")

    case .right:
      config.image = UIImage(named: "ic_rightArrow")
    }
    
    config.attributedTitle = AttributedString(title, attributes: titleContainer)
    config.imagePadding = 8
    config.imagePlacement = .trailing
    
    self.configuration = config
  }
}
