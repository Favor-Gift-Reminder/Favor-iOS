//
//  BaseSettingsCell.swift
//  Favor
//
//  Created by 이창준 on 7/1/23.
//

import UIKit

import FavorKit
import RxCocoa
import RxSwift
import SnapKit

public class BaseSettingsCell: BaseCollectionViewCell, Pressable, BaseView {

  // MARK: - Constants

  public enum Metric {
    static let rightIconSize: CGFloat = 10.0
    static let trailingInset: CGFloat = 8.0
    static let navigatableIconImageSize: CGFloat = 28.0
    static let toggleSwitchWidth: CGFloat = 40.0
    static let toggleSwitchHeight: CGFloat = 24.0
  }

  // MARK: - Properties

  public var pressedScale: Double = 1.0
  public var idleBackgroundColor: UIColor = .favorColor(.white)
  public var pressedBackgroundColor: UIColor = .favorColor(.background)

  public var cellModel: SettingsSectionItem?

  // MARK: - UI Components

  public var containerView = UIView()

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 16)
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

  public func bind(_ item: SettingsSectionItem) {
    self.cellModel = item
    self.titleLabel.text = item.title
  }

  // MARK: - UI Setups

  public func setupStyles() {
    self.layer.cornerRadius = 8
  }

  public func setupLayouts() {
    self.addSubview(self.containerView)

    self.containerView.addSubview(self.titleLabel)
  }

  public func setupConstraints() {
    self.containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    self.titleLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(Metric.trailingInset)
      make.centerY.equalToSuperview()
    }
  }
}
