//
//  NewProfileCell.swift
//  Favor
//
//  Created by 이창준 on 2023/02/12.
//

import UIKit

class NewProfileCell: UICollectionViewCell, ReuseIdentifying {
  
  // MARK: - UI Components
  
  // MARK: - Initializer
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Bind
  
  // TODO: reactor 주입하고 데이터 바인딩
}

// MARK: - Setup

extension NewProfileCell: BaseView {
  func setupStyles() {
    // TODO: 배경색 변경
    self.backgroundColor = .cyan
  }
  
  func setupLayouts() {
    //
  }
  
  func setupConstraints() {
    //
  }
}
