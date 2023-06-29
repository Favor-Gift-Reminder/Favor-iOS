//
//  SettingsCell.swift
//  Favor
//
//  Created by 이창준 on 6/29/23.
//

import UIKit

import FavorKit
import SnapKit

public final class SettingsCell: BaseCollectionViewCell, Pressable {

  // MARK: - Constants

  private enum Metric {
    static let rightIconSize: CGFloat = 10.0
    static let trailingInset: CGFloat = 8.0
  }

  // MARK: - Properties

  public var pressedScale: Double = 1.0

  public var idleBackgroundColor: UIColor = .favorColor(.white)
  public var pressedBackgroundColor: UIColor = .favorColor(.background)

  // MARK: - UI Components

  public var containerView = UIView()

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 16)
    label.textColor = .favorColor(.icon)
    return label
  }()

  private let authInfoLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 14)
    label.textColor = .favorColor(.subtext)
    label.textAlignment = .right
    label.isHidden = true
    return label
  }()

  private let toggleSwitch: FavorSwitch = {
    let toggleSwitch = FavorSwitch()
    toggleSwitch.isHidden = true
    return toggleSwitch
  }()

  private let infoLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 14)
    label.textColor = .favorColor(.main)
    label.textAlignment = .right
    label.isHidden = true
    return label
  }()

  private let selectIconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .favorIcon(.right)?
      .resize(newWidth: Metric.rightIconSize)
      .withTintColor(.favorColor(.line2))
    imageView.contentMode = .center
    imageView.isHidden = true
    return imageView
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

  public func bind(with item: SettingsSectionItem) {
    switch item {
    case let .selectable(_, _, title, info):
      self.titleLabel.text = title
      if let info = info { self.authInfoLabel.text = info }
      self.selectIconImageView.isHidden = false
      self.authInfoLabel.isHidden = false
      self.setupLongPressRecognizer()
    case let .switchable(_, _, title):
      self.titleLabel.text = title
      self.toggleSwitch.isHidden = false
    case let .info(_, _, title, info):
      self.titleLabel.text = title
      self.infoLabel.text = info
      self.infoLabel.isHidden = false
      self.setupLongPressRecognizer()
    }
  }
}

// MARK: - UI Setups

extension SettingsCell: BaseView {
  public func setupStyles() {
    self.layer.cornerRadius = 8
  }

  public func setupLayouts() {
    self.addSubview(self.containerView)

    [
      self.titleLabel,
      self.authInfoLabel,
      self.selectIconImageView,
      self.toggleSwitch,
      self.infoLabel
    ].forEach {
      self.containerView.addSubview($0)
    }
  }

  public func setupConstraints() {
    self.containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    self.titleLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(Metric.trailingInset)
      make.centerY.equalToSuperview()
    }

    self.selectIconImageView.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(Metric.trailingInset)
      make.centerY.equalToSuperview()
      make.width.height.equalTo(28.0)
    }

    self.authInfoLabel.snp.makeConstraints { make in
      make.trailing.equalTo(self.selectIconImageView.snp.leading).offset(-8.0)
      make.centerY.equalToSuperview()
    }

    self.toggleSwitch.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(Metric.trailingInset)
      make.centerY.equalToSuperview()
      make.width.equalTo(40.0)
      make.height.equalTo(24.0)
    }

    self.infoLabel.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(Metric.trailingInset + 9.0)
      make.centerY.equalToSuperview()
    }
  }
}
