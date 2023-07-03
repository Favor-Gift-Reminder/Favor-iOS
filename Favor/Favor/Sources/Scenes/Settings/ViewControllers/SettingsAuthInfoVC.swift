//
//  SettingsAuthInfoVC.swift
//  Favor
//
//  Created by 이창준 on 6/29/23.
//

import OSLog
import UIKit

import FavorKit
import ReactorKit
import SnapKit

public final class SettingsAuthInfoViewController: BaseViewController, View {

  // MARK: - Constants

  private enum Metric {
    static let verticalInset: CGFloat = 32.0
    static let horizontalInset: CGFloat = 12.0
    static let authInfoViewHeight: CGFloat = 100.0
    static let buttonHeight: CGFloat = 56.0
    static let buttonCornerRadius: CGFloat = 8.0
    static let deleteAccountDescriptionNumberOfLines: Int = 3
  }

  private enum Typo {
    static let signoutButtonTitle: String = "로그아웃"
    static let deleteAccountButtonTitle: String = "회원탈퇴"
    static let cancelButtonTitle: String = "취소"
    static let signoutAcceptButtonTitle: String = "로그아웃"
    static let deleteAccountAcceptButtonTitle: String = "탈퇴"
    static let signoutPopupTitle: String = "로그아웃 하시겠습니까?"
    static let deleteAccountPopupTitle: String = "회원 탈퇴하기"
    static let deleteAccountDescription: String = """
      회원님의 모든 기록이 삭제됩니다.
      삭제된 정보는 복구할 수 없습니다.
      지금 탈퇴하시겠습니까?
      """
  }

  private enum PopupIdentifier {
    static let signout = "signout"
    static let deleteAccount = "deleteAccount"
  }

  // MARK: - Properties

  private var keychain: KeychainManager

  // MARK: - UI Components

  private lazy var authInfoView = SettingsAuthInfoView(keychain: self.keychain)

  private lazy var signoutButton = self.makeButton(title: Typo.signoutButtonTitle)
  private lazy var deleteAccountButton = self.makeButton(title: Typo.deleteAccountButtonTitle)

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
    self.signoutButton.rx.tap
      .map { Reactor.Action.signoutButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.deleteAccountButton.rx.tap
      .map { Reactor.Action.deleteAccountDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // State
    reactor.pulse { $0.$signoutPulse }
      .filter { $0 }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self, onNext: { owner, _ in
        owner.presentSignOutPopup()
      })
      .disposed(by: self.disposeBag)

    reactor.pulse { $0.$deleteAccountPulse }
      .filter { $0 }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self, onNext: { owner, _ in
        owner.presentDeleteAccountPopup()
      })
      .disposed(by: self.disposeBag)
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
      self.signoutButton,
      self.deleteAccountButton
    ].forEach {
      self.buttonStackView.addArrangedSubview($0)
    }
  }

  public override func setupConstraints() {
    self.authInfoView.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(Metric.verticalInset)
      make.directionalHorizontalEdges.equalToSuperview()
      make.height.equalTo(Metric.authInfoViewHeight)
    }

    self.buttonStackView.snp.makeConstraints { make in
      make.top.equalTo(self.authInfoView.snp.bottom).offset(Metric.verticalInset)
      make.directionalHorizontalEdges.equalToSuperview().inset(Metric.horizontalInset)
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
    button.layer.cornerRadius = Metric.buttonCornerRadius
    button.clipsToBounds = true
    button.contentHorizontalAlignment = .leading

    button.snp.makeConstraints { make in
      make.height.equalTo(Metric.buttonHeight)
    }

    return button
  }

  func presentSignOutPopup() {
    let actions = NewAlertPopup.ActionButtons(
      reject: Typo.cancelButtonTitle,
      accept: Typo.signoutAcceptButtonTitle
    )
    let signOutPopup = NewAlertPopup(
      .onlyTitle(title: Typo.signoutPopupTitle, actions),
      identifier: PopupIdentifier.signout
    )
    signOutPopup.modalPresentationStyle = .overFullScreen
    signOutPopup.delegate = self

    DispatchQueue.main.async {
      self.present(signOutPopup, animated: false)
    }
  }

  func presentDeleteAccountPopup() {
    let description = NewAlertPopup.Description(
      description: Typo.deleteAccountDescription,
      numberOfLines: Metric.deleteAccountDescriptionNumberOfLines
    )
    let actions = NewAlertPopup.ActionButtons(
      reject: Typo.cancelButtonTitle,
      accept: Typo.deleteAccountAcceptButtonTitle
    )
    let deleteAccountPopup = NewAlertPopup(
      .titleWithDescription(
        title: Typo.deleteAccountPopupTitle,
        description: description,
        actions
      ),
      identifier: PopupIdentifier.deleteAccount
    )
    deleteAccountPopup.modalPresentationStyle = .overFullScreen
    deleteAccountPopup.delegate = self

    DispatchQueue.main.async {
      self.present(deleteAccountPopup, animated: false)
    }
  }
}

// MARK: - Popup

extension SettingsAuthInfoViewController: AlertPopupDelegate {
  public func actionDidSelected(_ isAccepted: Bool, from identifier: String) {
    guard let reactor = self.reactor else { return }

    if isAccepted {
      switch title {
      case PopupIdentifier.signout:
        reactor.action.onNext(.signoutDidRequested)
      case PopupIdentifier.deleteAccount:
        reactor.action.onNext(.deleteAccountDidRequested)
      default:
        os_log(.error, "Unknown identifier for popup.")
      }
    } else {
      guard let popup = self.presentedViewController as? NewAlertPopup else { return }
      popup.dismissPopup()
    }
  }
}
