//
//  FavorDivider.swift
//  Favor
//
//  Created by 김응철 on 2023/02/16.
//

import UIKit

import SnapKit

final class FavorDivider: UIView {
  
  // MARK: - INITIALIZER
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension FavorDivider: BaseView {
  func setupStyles() {
    self.backgroundColor = .favorColor(.divider)
  }
  
  func setupLayouts() {}
  
  func setupConstraints() {
    self.snp.makeConstraints { make in
      make.height.equalTo(1)
    }
  }
}
