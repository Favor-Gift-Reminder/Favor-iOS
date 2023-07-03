//
//  SettingsNaviagatableCell.swift
//  Favor
//
//  Created by 이창준 on 7/1/23.
//

import UIKit

import SnapKit

public final class SettingsNaviagatableCell: BaseSettingsCell {

  // MARK: - UI Components

  private let navigatableImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .favorIcon(.right)?
      .resize(newWidth: Metric.rightIconSize)
      .withTintColor(.favorColor(.line2))
    imageView.contentMode = .center
    return imageView
  }()

  private let subtitleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 14)
    label.textColor = .favorColor(.subtext)
    label.textAlignment = .right
    return label
  }()

  // MARK: - Functions

  public override func bind(_ item: SettingsSectionItem) {
    super.bind(item)
    guard case SettingsSectionItem.CellType.navigatable = item.type else { return }

    self.subtitleLabel.text = item.subtitle
  }

  // MARK: - UI Setups

  public override func setupStyles() {
    super.setupStyles()

    self.setupLongPressRecognizer()
  }

  public override func setupLayouts() {
    super.setupLayouts()

    [
      self.navigatableImageView,
      self.subtitleLabel
    ].forEach {
      self.containerView.addSubview($0)
    }
  }

  public override func setupConstraints() {
    super.setupConstraints()

    self.navigatableImageView.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(Metric.trailingInset)
      make.centerY.equalToSuperview()
      make.width.height.equalTo(Metric.navigatableIconImageSize)
    }

    self.subtitleLabel.snp.makeConstraints { make in
      make.trailing.equalTo(self.navigatableImageView.snp.leading).offset(-8.0)
      make.centerY.equalToSuperview()
    }
  }
}
