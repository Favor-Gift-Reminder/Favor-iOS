//
//  GiftManagementMemoCell.swift
//  Favor
//
//  Created by 이창준 on 2023/05/29.
//

import UIKit

import FavorKit
import RSKPlaceholderTextView
import SnapKit

final class GiftManagementMemoCell: BaseCollectionViewCell {

  // MARK: - UI Components

  private let memoView: RSKPlaceholderTextView = {
    let textView = RSKPlaceholderTextView()
    return textView
  }()

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

// MARK: - UI Setups

extension GiftManagementMemoCell: BaseView {
  func setupStyles() {
    //
  }

  func setupLayouts() {

  }

  func setupConstraints() {
    //
  }
}
