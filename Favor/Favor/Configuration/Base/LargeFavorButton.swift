//
//  FavorButton.swift
//  Favor
//
//  Created by 김응철 on 2023/01/15.
//

import UIKit

final class LargeFavorButton: UIButton {
  
  enum Style {
    case black
    case white
  }
  
  // MARK: - Initializer
  
  init(with style: Style, title: String) {
    super.init(frame: .zero)
    setupConfiguration(with: style, title: title)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  private func setupConfiguration(with style: Style, title: String) {
    var config = UIButton.Configuration.filled()
    var container = AttributeContainer()
    container.font = .favorFont(.bold, size: 18)
    config.attributedTitle = AttributedString(title, attributes: container)
    
    config.background.cornerRadius = 28
    
    switch style {
    case .white:
      config.baseForegroundColor = .favorColor(.typo)
      config.baseBackgroundColor = .favorColor(.box1)
      
    case .black:
      config.baseForegroundColor = .favorColor(.white)
      config.baseBackgroundColor = .favorColor(.typo)
    }
    
    self.configuration = config
  }
}
