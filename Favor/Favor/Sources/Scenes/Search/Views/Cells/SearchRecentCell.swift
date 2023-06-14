//
//  SearchRecentCell.swift
//  Favor
//
//  Created by 이창준 on 2023/04/11.
//

import UIKit

import FavorKit
import SnapKit

final class SearchRecentCell: BaseCollectionViewCell {

  // MARK: - UI Components

  private let iconImageView: UIImageView = {
    let imageView = UIImageView(image: .favorIcon(.search))
    imageView.contentMode = .center
    return imageView
  }()

  private lazy var textLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 14)
    label.text = "검색 기록"
    return label
  }()

  private let deleteButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.background.backgroundColor = .clear
    config.baseForegroundColor = .favorColor(.line2)
    config.image = .favorIcon(.close)?.resize(newWidth: 12)

    let button = UIButton(configuration: config)
    return button
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

  public func bind(with text: String) {
    self.textLabel.text = text
  }
}

// MARK: - UI Setups

extension SearchRecentCell: BaseView {
  func setupStyles() {
    self.backgroundColor = .clear
  }

  func setupLayouts() {
    [
      self.iconImageView,
      self.textLabel,
      self.deleteButton
    ].forEach {
      self.addSubview($0)
    }
  }

  func setupConstraints() {
    self.iconImageView.snp.makeConstraints { make in
      make.leading.directionalVerticalEdges.equalToSuperview()
    }

    self.textLabel.snp.makeConstraints { make in
      make.leading.equalTo(self.iconImageView.snp.trailing).offset(8)
      make.centerY.equalToSuperview()
    }

    self.deleteButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview()
      make.centerY.equalToSuperview()
      make.width.height.equalTo(12)
    }
  }
}
