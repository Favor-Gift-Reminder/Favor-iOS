//
//  FavorButton.swift
//  Favor
//
//  Created by 김응철 on 2023/01/15.
//

import UIKit

import SnapKit

final class FavorLargeButton: UIButton {
  
  // MARK: - PROPERTIES
  
  private let largeFavorButtonType: LargeFavorButtonType
  
  // MARK: - INITIALIZER
  
  init(with largeFavorButtonType: LargeFavorButtonType) {
    self.largeFavorButtonType = largeFavorButtonType
    super.init(frame: .zero)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension FavorLargeButton: BaseView {
  func setupStyles() {
    self.configuration = self.largeFavorButtonType.configuration
  }
  
  func setupLayouts() {}
  
  func setupConstraints() {
    self.snp.makeConstraints { make in
      make.height.equalTo(56)
    }
  }
}
