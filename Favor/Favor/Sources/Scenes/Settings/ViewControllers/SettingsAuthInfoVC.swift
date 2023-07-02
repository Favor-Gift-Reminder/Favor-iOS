//
//  SettingsAuthInfoVC.swift
//  Favor
//
//  Created by 이창준 on 6/29/23.
//

import UIKit

import FavorKit
import ReactorKit
import SnapKit

public final class SettingsAuthInfoViewController: BaseViewController, View {

  // MARK: - Constants

  // MARK: - Properties

  private var keychain: KeychainManager

  // MARK: - UI Components

  private lazy var authInfoView = SettingsAuthInfoView(keychain: self.keychain)

  private lazy var signOutButton = self.makeButton(title: "로그아웃")
  private lazy var deleteAccountButton = self.makeButton(title: "회원탈퇴")

  private let buttonStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 4
    return stackView
  }()

  // MARK: - Initializer

  public init(keychain: KeychainManager) {
    self.keychain = keychain
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycle

  // MARK: - Binding

  public func bind(reactor: SettingsAuthInfoViewReactor) {
    // Action
    self.signOutButton.rx.tap
      .map { Reactor.Action.signOutButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.deleteAccountButton.rx.tap
      .map { Reactor.Action.deleteAccountDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // State

  }

  // MARK: - Functions

  // MARK: - UI Setups

  public override func setupLayouts() {
    [
      self.authInfoView,
      self.buttonStackView
    ].forEach {
      self.view.addSubview($0)
    }

    [
      self.signOutButton,
      self.deleteAccountButton
    ].forEach {
      self.buttonStackView.addArrangedSubview($0)
    }
  }

  public override func setupConstraints() {
    self.authInfoView.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(32.0)
      make.directionalHorizontalEdges.equalToSuperview()
      make.height.equalTo(100.0)
    }

    self.buttonStackView.snp.makeConstraints { make in
      make.top.equalTo(self.authInfoView.snp.bottom).offset(32.0)
      make.directionalHorizontalEdges.equalToSuperview().inset(12.0)
    }
  }
}

// MARK: - Privates

private extension SettingsAuthInfoViewController {
  func makeButton(title: String) -> UIButton {
    var config = UIButton.Configuration.filled()
    config.updateAttributedTitle(title, font: .favorFont(.regular, size: 16))
    config.baseForegroundColor = .favorColor(.icon)
    config.contentInsets = NSDirectionalEdgeInsets(top: .zero, leading: 8.0, bottom: .zero, trailing: 8.0)

    let button = UIButton(configuration: config)
    button.configurationUpdateHandler = { button in
      switch button.state {
      case .normal:
        button.configuration?.baseBackgroundColor = .clear
      case .highlighted:
        button.configuration?.baseBackgroundColor = .favorColor(.background)
      default:
        break
      }
    }
    button.layer.cornerRadius = 8
    button.clipsToBounds = true
    button.contentHorizontalAlignment = .leading

    button.snp.makeConstraints { make in
      make.height.equalTo(56.0)
    }

    return button
  }
}
