//
//  AuthInfoView.swift
//  Favor
//
//  Created by 이창준 on 7/1/23.
//

import UIKit

import FavorKit

public final class SettingsAuthInfoView: UIView {

  // MARK: - Constants

  private enum Metric {
    static let horizontalInset: CGFloat = 20.0
    static let socialAuthImageSize: CGFloat = 24.0
  }

  // MARK: - Properties

  private var keychain: KeychainManager?

  // MARK: - UI Components

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 16)
    label.textColor = .favorColor(.icon)
    return label
  }()

  private let socialAuthImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = Metric.socialAuthImageSize / 2
    imageView.clipsToBounds = true
    imageView.contentMode = .center
    return imageView
  }()

  private let subtitleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 14)
    label.textColor = .favorColor(.subtext)
    return label
  }()

  private let contentStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 12
    return stackView
  }()

  private let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.contentMode = .center
    stackView.spacing = 12
    return stackView
  }()

  // MARK: - Initializer

  private override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }

  public convenience init(keychain: KeychainManager) {
    self.init(frame: .zero)
    self.keychain = keychain
    self.setupData()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions

  private func setupData() {
    self.titleLabel.text = FTUXStorage.authState.isSocialAuth ? "소셜 연동" : "이메일 연동"
    self.socialAuthImageView.isHidden = !FTUXStorage.authState.isSocialAuth
    self.socialAuthImageView.backgroundColor = FTUXStorage.authState.backgroundColor
    self.socialAuthImageView.image = FTUXStorage.authState.icon?
      .resize(newWidth: 12)
    if
      let keychain = self.keychain,
      let emailData = try? keychain.get(account: KeychainManager.Accounts.userEmail.rawValue)
    {
      self.subtitleLabel.text = String(decoding: emailData, as: UTF8.self)
    }
  }
}

// MARK: - UI Setups

extension SettingsAuthInfoView: BaseView {
  public func setupStyles() {
    self.backgroundColor = .favorColor(.card)
  }

  public func setupLayouts() {
    self.addSubview(self.stackView)

    [
      self.titleLabel,
      self.contentStackView
    ].forEach {
      self.stackView.addArrangedSubview($0)
    }

    [
      self.socialAuthImageView,
      self.subtitleLabel
    ].forEach {
      self.contentStackView.addArrangedSubview($0)
    }
  }

  public func setupConstraints() {
    self.stackView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.directionalHorizontalEdges.equalToSuperview().inset(Metric.horizontalInset)
    }

    self.socialAuthImageView.snp.makeConstraints { make in
      make.width.height.equalTo(Metric.socialAuthImageSize)
    }
  }
}
