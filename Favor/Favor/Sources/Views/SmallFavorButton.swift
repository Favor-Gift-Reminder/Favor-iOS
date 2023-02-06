//
//  SmallFavorButton.swift
//  Favor
//
//  Created by 김응철 on 2023/01/16.
//

import UIKit

final class SmallFavorButton: UIButton {
  
  enum Style {
    case black
    case white
  }
  
  // MARK: - Initializer
  
  init(_ with: Style, title: String, image: UIImage? = nil) {
    super.init(frame: .zero)
    setupConfiguration(with, title: title, image: image)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  private func setupConfiguration(_ style: Style, title: String, image: UIImage?) {
    var config = UIButton.Configuration.filled()
    var container = AttributeContainer()
    container.font = .favorFont(.bold, size: 12)
    config.attributedTitle = AttributedString(title, attributes: container)
    
    config.image = image
    config.imagePadding = 8
    config.imagePlacement = .leading
    
    config.background.cornerRadius = 12
    
    switch style {
    case .white:
      config.baseBackgroundColor = .favorColor(.line3)
      config.baseForegroundColor = .favorColor(.titleAndLine)
      
    case .black:
      config.baseBackgroundColor = .favorColor(.titleAndLine)
      config.baseForegroundColor = .favorColor(.white)
    }
    
    self.configuration = config
  }
}
