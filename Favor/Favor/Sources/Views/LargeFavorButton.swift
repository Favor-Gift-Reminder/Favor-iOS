//
//  FavorButton.swift
//  Favor
//
//  Created by 김응철 on 2023/01/15.
//

import UIKit

import SnapKit

final class LargeFavorButton: UIButton {
  
  enum Style {
    case black
    case white
  }
  
  // MARK: - Initializer
  
  init(with style: Style, title: String) {
    super.init(frame: .zero)
    setupConfiguration(with: style, title: title)
    self.snp.makeConstraints { make in
      make.height.equalTo(56.0)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  private func setupConfiguration(with style: Style, title: String) {
    var config = UIButton.Configuration.filled()
    var container = AttributeContainer()
    container.font = .favorFont(.bold, size: 18)
    
    config.background.cornerRadius = 28
    
    switch style {
    case .white:
      container.foregroundColor = .favorColor(.titleAndLine)
      config.baseBackgroundColor = .favorColor(.line3)
      
    case .black:
      container.foregroundColor = .favorColor(.white)
      config.baseBackgroundColor = .favorColor(.titleAndLine)
    }
    
    config.attributedTitle = AttributedString(title, attributes: container)
    self.configuration = config
  }
}
