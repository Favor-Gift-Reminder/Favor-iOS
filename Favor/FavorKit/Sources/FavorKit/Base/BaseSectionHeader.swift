//
//  BaseSectionHeader.swift
//  Favor
//
//  Created by 이창준 on 2023/04/28.
//

import UIKit

import SnapKit

open class BaseSectionHeader: UICollectionReusableView, BaseView {

  // MARK: - UI Components

  public let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 18)
    label.text = "Section Header"
    return label
  }()

  // MARK: - Initializer

  public override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions

  public func update(title: String) {
    self.titleLabel.text = title
  }

  // MARK: - UI Setups

  open func setupStyles() {
    self.backgroundColor = .clear
  }

  open func setupLayouts() {
    self.addSubview(self.titleLabel)
  }

  open func setupConstraints() {
    self.titleLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.directionalVerticalEdges.equalToSuperview()
    }
  }
}
