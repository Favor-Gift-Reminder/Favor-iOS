//
//  SettingsTappableCell.swift
//  Favor
//
//  Created by 이창준 on 7/1/23.
//

import UIKit

import SnapKit

public final class SettingsTappableCell: BaseSettingsCell {

  // MARK: - UI Components

  private let staticInfoLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 14)
    label.textColor = .favorColor(.main)
    label.textAlignment = .right
    return label
  }()

  // MARK: - Functions

  public override func bind(_ item: SettingsSectionItem) {
    super.bind(item)
    guard case SettingsSectionItem.CellType.tappable = item.type else { return }

    self.staticInfoLabel.text = item.staticInfo
  }

  // MARK: - UI Setups

  public override func setupStyles() {
    super.setupStyles()

    self.setupLongPressRecognizer()
  }

  public override func setupLayouts() {
    super.setupLayouts()

    self.containerView.addSubview(self.staticInfoLabel)
  }

  public override func setupConstraints() {
    super.setupConstraints()

    self.staticInfoLabel.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(Metric.trailingInset + 9.0)
      make.centerY.equalToSuperview()
    }
  }
}
