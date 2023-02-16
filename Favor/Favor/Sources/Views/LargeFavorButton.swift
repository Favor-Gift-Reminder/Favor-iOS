//
//  FavorButton.swift
//  Favor
//
//  Created by 김응철 on 2023/01/15.
//

import UIKit

import SnapKit

final class LargeFavorButton: UIButton {
  
  // MARK: - PROPERTIES
  
  private let largeFavorButtonType: LargeFavorButtonType
  private let title: String
  
  // MARK: - INITIALIZER
  
  init(with largeFavorButtonType: LargeFavorButtonType, title: String) {
    self.largeFavorButtonType = largeFavorButtonType
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

extension LargeFavorButton: BaseView {
  func setupStyles() {
    var container = AttributeContainer()
    container.font = .favorFont(.bold, size: 18)
    self.configuration = self.largeFavorButtonType.configuration
    self.configuration?.attributedTitle = AttributedString(
      self.title,
      attributes: container
    )
  }
  
  func setupLayouts() {}
  
  func setupConstraints() {
    self.snp.makeConstraints { make in
      make.height.equalTo(56)      
    }
  }
}
