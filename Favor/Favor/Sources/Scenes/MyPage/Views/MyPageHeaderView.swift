//
//  MyPageHeaderView.swift
//  Favor
//
//  Created by 이창준 on 2023/02/13.
//

import UIKit

import ReactorKit
import SnapKit

final class MyPageHeaderView: UICollectionReusableView, ReuseIdentifying {
  
  // MARK: - Properties
  
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
}

extension MyPageHeaderView: BaseView {
  func setupStyles() {
    //
  }
  
  func setupLayouts() {
    //
  }
  
  func setupConstraints() {
    //
  }
}
