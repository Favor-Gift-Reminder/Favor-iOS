//
//  FavorPlainButton.swift
//  Favor
//
//  Created by 김응철 on 2023/01/20.
//

import UIKit

final class FavorPlainButton: UIButton {
  
  // MARK: - PROPERTIES
  
  private let plainFavorButtonType: PlainFavorButtonType

  // MARK: - INITIALIZER
  
  init(with plainFavorButtonType: PlainFavorButtonType) {
    self.plainFavorButtonType = plainFavorButtonType
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

extension FavorPlainButton: BaseView {
  func setupStyles() {
    self.configuration = self.plainFavorButtonType.configuration
  }
  
  func setupLayouts() {}
  func setupConstraints() {}
}
