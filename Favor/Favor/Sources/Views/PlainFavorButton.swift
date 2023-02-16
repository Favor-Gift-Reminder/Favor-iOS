//
//  PlainFavorButton.swift
//  Favor
//
//  Created by 김응철 on 2023/01/20.
//

import UIKit

final class PlainFavorButton: UIButton {
  
  // MARK: - PROPERTIES
  
  private let plainFavorButtonType: PlainFavorButtonType
  private let title: String

  // MARK: - INITIALIZER
  
  init(with plainFavorButtonType: PlainFavorButtonType, title: String) {
    self.plainFavorButtonType = plainFavorButtonType
    self.title = title
    super.init(frame: .zero)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - SETUP

extension PlainFavorButton: BaseView {
  func setupStyles() {
    var container = AttributeContainer()
    var config = UIButton.Configuration.plain()
    config.imagePadding = 8
    config.imagePlacement = .trailing
    config.baseForegroundColor = .favorColor(.subtext)
    switch self.plainFavorButtonType {
    case .log_in:
      container.font = .favorFont(.regular, size: 14)
      config.image = UIImage(named: "ic_right_gray")
    case .more:
      container.font = .favorFont(.regular, size: 12)
    case .main(let isRight):
      container.font = .favorFont(.regular, size: 16)
      if isRight {
        config.image = UIImage(named: "ic_right_gray")
      } else {
        config.image = UIImage(named: "ic_down_gray")
      }
    }
    
    config.attributedTitle = AttributedString(
      self.title,
      attributes: container
    )
    self.configuration = config
  }
  
  func setupLayouts() {}
  func setupConstraints() {}
}
