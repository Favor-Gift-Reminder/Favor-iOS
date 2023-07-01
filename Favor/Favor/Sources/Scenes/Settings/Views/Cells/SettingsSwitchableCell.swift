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

  private let toggleSwitch = FavorSwitch()

  // MARK: - Initializer

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.bind()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions

  public override func bind(_ item: SettingsSectionItem) {
    super.bind(item)
    guard case let SettingsSectionItem.CellType.switchable(initialValue, _) = item.type else { return }

    self.toggleSwitch.rx.isOn.onNext(initialValue)
  }

  // MARK: - Binding

  private func bind() {
    self.toggleSwitch.rx.isOn
      .distinctUntilChanged()
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self, onNext: { owner, isOn in
        guard let item = self.cellModel else { return }
        owner.delegate?.switchDidToggle(item, to: isOn)
      })
      .disposed(by: self.disposeBag)
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
