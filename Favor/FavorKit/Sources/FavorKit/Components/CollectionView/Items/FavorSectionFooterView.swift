//
//  FavorSectionFooterView.swift
//  Favor
//
//  Created by 이창준 on 2023/05/02.
//

import UIKit

import Reusable
import SnapKit

open class FavorSectionFooterView: UICollectionReusableView, Reusable {

  // MARK: - Properties

  public var footerDescription: String? {
    didSet { self.updateDescriptionLabel() }
  }

  // MARK: - UI Components

  private let divider = FavorDivider()

  private let descriptionLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 12)
    label.textColor = .favorColor(.line2)
    label.isHidden = true
    return label
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
}

// MARK: - UI Setups

extension FavorSectionFooterView: BaseView {
  public func setupStyles() {
    //
  }

  public func setupLayouts() {
    [
      self.divider,
      self.descriptionLabel
    ].forEach {
      self.addSubview($0)
    }
  }

  public func setupConstraints() {
    self.divider.snp.makeConstraints { make in
      make.top.directionalHorizontalEdges.equalToSuperview()
      make.height.equalTo(1)
    }

    self.descriptionLabel.snp.makeConstraints { make in
      make.top.equalTo(self.divider.snp.bottom).offset(12)
      make.directionalHorizontalEdges.equalToSuperview()
    }
  }
}

// MARK: - Privates

private extension FavorSectionFooterView {
  func updateDescriptionLabel() {
    self.descriptionLabel.text = self.footerDescription
    self.descriptionLabel.isHidden = false
  }
}
