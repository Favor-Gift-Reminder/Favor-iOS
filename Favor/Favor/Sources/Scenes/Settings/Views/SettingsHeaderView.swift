//
//  SettingsHeaderView.swift
//  Favor
//
//  Created by 이창준 on 6/29/23.
//

import UIKit

import FavorKit
import SnapKit

public final class SettingsHeaderView: UICollectionReusableView {

  // MARK: - Properties

  // MARK: - UI Components

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 14)
    label.textColor = .favorColor(.explain)
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

  public func bind(with title: String) {
    self.titleLabel.text = title
  }
}

// MARK: - UI Setups

extension SettingsHeaderView: BaseView {
  public func setupStyles() {
    //
  }

  public func setupLayouts() {
    self.addSubview(self.titleLabel)
  }

  public func setupConstraints() {
    self.titleLabel.snp.makeConstraints { make in
      make.directionalVerticalEdges.equalToSuperview()
      make.directionalHorizontalEdges.equalToSuperview().inset(8.0)
    }
  }
}
