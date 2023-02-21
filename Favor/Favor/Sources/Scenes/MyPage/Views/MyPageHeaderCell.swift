//
//  MyPageHeaderCell.swift
//  Favor
//
//  Created by 이창준 on 2023/02/17.
//

import UIKit

final class MyPageHeaderCell: UICollectionViewCell, ReuseIdentifying {

  // MARK: - Constants

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

  // MARK: - Functions

  // MARK: - UI Setups

}

extension MyPageHeaderCell: BaseView {
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
