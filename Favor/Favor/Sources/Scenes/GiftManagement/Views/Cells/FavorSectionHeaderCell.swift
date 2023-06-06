//
//  FavorSectionHeaderCell.swift
//  Favor
//
//  Created by 이창준 on 2023/06/02.
//

import UIKit

import FavorKit
import SnapKit

open class FavorSectionHeaderCell: BaseCollectionViewCell {

  // MARK: - UI Components

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 18)
    label.text = "섹션 헤더"
    return label
  }()

  private let digitInfoLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 18)
    label.text = "-1"
    label.isHidden = true
    return label
  }()

  private let labelStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 8
    return stackView
  }()

  // MARK: - Initializer

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }

  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions
  
  public func bind(title: String, digit: Int? = nil) {
    self.titleLabel.text = title
    self.digitInfoLabel.isHidden = digit == nil
    self.digitInfoLabel.text = digit == nil ? nil : String(digit!)
  }
}

// MARK: - UI Setups

extension FavorSectionHeaderCell: BaseView {
  public func setupStyles() {
    //
  }

  public func setupLayouts() {
    [
      self.titleLabel,
      self.digitInfoLabel
    ].forEach {
      self.labelStack.addArrangedSubview($0)
    }

    self.addSubview(self.labelStack)
  }

  public func setupConstraints() {
    self.labelStack.snp.makeConstraints { make in
      make.directionalVerticalEdges.leading.equalToSuperview()
    }
  }
}
