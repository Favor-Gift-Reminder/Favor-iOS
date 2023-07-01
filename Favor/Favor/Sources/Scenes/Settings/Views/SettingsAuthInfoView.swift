//
//  AuthInfoView.swift
//  Favor
//
//  Created by 이창준 on 7/1/23.
//

import UIKit

import FavorKit

public final class SettingsAuthInfoView: UIView {

  // MARK: - UI Components

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 16)
    label.textColor = .favorColor(.icon)
    return label
  }()

  private let subtitleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 14)
    label.textColor = .favorColor(.subtext)
    return label
  }()

  private let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    return stackView
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

}

// MARK: - UI Setups

extension SettingsAuthInfoView: BaseView {
  public func setupStyles() {
    self.backgroundColor = .favorColor(.card)
  }

  public func setupLayouts() {
    [
      self.titleLabel,
      self.stackView
    ].forEach {
      self.addSubview($0)
    }
    
    [
      //
      self.subtitleLabel
    ].forEach {
      self.stackView.addArrangedSubview($0)
    }
  }

  public func setupConstraints() {
    self.titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(21)
      make.directionalHorizontalEdges.equalToSuperview().inset(20.0)
    }
  }
}
