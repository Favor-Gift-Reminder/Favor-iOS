//
//  SettingsSwitchableCell.swift
//  Favor
//
//  Created by 이창준 on 7/1/23.
//

import UIKit

import FavorKit
import RxCocoa
import RxSwift
import SnapKit

public protocol SettingsSwitchableCellDelegate: AnyObject {
  func switchDidToggle(_ item: SettingsSectionItem, to isOn: Bool)
}

public final class SettingsSwitchableCell: BaseSettingsCell {

  // MARK: - Properties

  public weak var delegate: SettingsSwitchableCellDelegate?

  // MARK: - UI Components

  private lazy var toggleSwitch: FavorSwitch = {
    let toggleSwitch = FavorSwitch()
    toggleSwitch.delegate = self
    return toggleSwitch
  }()

  // MARK: - Functions

  public override func bind(_ item: SettingsSectionItem) {
    super.bind(item)
    guard case let SettingsSectionItem.CellType.switchable(initialValue, _) = item.type else { return }

    print(initialValue)
    self.toggleSwitch.isOn = initialValue
  }

  // MARK: - UI Setups

  public override func setupLayouts() {
    super.setupLayouts()

    self.containerView.addSubview(self.toggleSwitch)
  }

  public override func setupConstraints() {
    super.setupConstraints()

    self.toggleSwitch.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(Metric.trailingInset)
      make.centerY.equalToSuperview()
      make.width.equalTo(Metric.toggleSwitchWidth)
      make.height.equalTo(Metric.toggleSwitchHeight)
    }
  }
}

// MARK: - Favor Switch

extension SettingsSwitchableCell: FavorSwitchDelegate {
  public func switchDidToggled(to state: Bool) {
    guard let item = self.cellModel else { return }
    self.delegate?.switchDidToggle(item, to: state)
  }
}
