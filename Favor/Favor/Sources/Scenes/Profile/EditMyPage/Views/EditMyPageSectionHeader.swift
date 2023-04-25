//
//  EditMyPageSectionHeader.swift
//  Favor
//
//  Created by 이창준 on 2023/04/25.
//

import UIKit

import FavorKit
import Reusable
import SnapKit

final class EditMyPageSectionHeader: UICollectionReusableView, Reusable {

  // MARK: - UI Components

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 18)
    label.textColor = .favorColor(.icon)
    return label
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

  // MARK: - Functions

  public func bind(with title: String) {
    self.titleLabel.text = title
  }
}

// MARK: - UI Setup

extension EditMyPageSectionHeader: BaseView {
  func setupStyles() {
    //
  }

  func setupLayouts() {
    self.addSubview(self.titleLabel)
  }

  func setupConstraints() {
    self.titleLabel.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
