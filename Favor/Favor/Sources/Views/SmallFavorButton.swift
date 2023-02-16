//
//  SmallFavorButton.swift
//  Favor
//
//  Created by 김응철 on 2023/01/16.
//

import UIKit

import SnapKit

final class SmallFavorButton: UIButton {
  
  // MARK: - PROPERTIES
  
  private let smallFavorButtonType: SmallFavorButtonType
  
  // MARK: - INITIALIZER
  
  init(with smallFavorButtonType: SmallFavorButtonType) {
    self.smallFavorButtonType = smallFavorButtonType
    super.init(frame: .zero)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension SmallFavorButton: BaseView {
  func setupStyles() {
    self.configuration = self.smallFavorButtonType.configuration
  }
  
  func setupLayouts() {}
  
  func setupConstraints() {
    self.snp.makeConstraints { make in
      make.height.equalTo(32)
    }
  }
}
