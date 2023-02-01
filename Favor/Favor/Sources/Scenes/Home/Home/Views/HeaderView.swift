//
//  HeaderView.swift
//  Favor
//
//  Created by 이창준 on 2023/02/01.
//

import UIKit

// FIXME: 대충 지은 이름
class HeaderView: UICollectionReusableView, ReuseIdentifying {
  
  // MARK: - Properties
  
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
}

extension HeaderView: BaseView {
  func setupStyles() {
    self.backgroundColor = .yellow
  }
  
  func setupLayouts() {
    //
  }
  
  func setupConstraints() {
    //
  }
}
