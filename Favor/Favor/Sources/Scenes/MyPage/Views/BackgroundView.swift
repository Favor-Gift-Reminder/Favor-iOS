//
//  BackgroundView.swift
//  Favor
//
//  Created by 이창준 on 2023/02/16.
//

import UIKit

final class BackgroundView: UICollectionReusableView, ReuseIdentifying {
  
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

// MARK: - Setup

extension BackgroundView: BaseView {
  func setupStyles() {
    self.backgroundColor = .favorColor(.background)
  }
  
  func setupLayouts() {
    //
  }
  
  func setupConstraints() {
    //
  }
}
