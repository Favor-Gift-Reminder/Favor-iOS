//
//  SettingsNewPasswordVC.swift
//  Favor
//
//  Created by 이창준 on 6/29/23.
//

import UIKit

import FavorKit
import ReactorKit
import SnapKit

public final class SettingsNewPasswordViewController: BaseViewController, View {

  // MARK: - Constants

  private enum Typo {
    static let currentPlaceholder: String = "현재 비밀번호"
    static let currentDescription: String = "기존 비밀번호를 입력해주세요."
    static let newPlaceholder: String = "새 비밀번호"
    static let newDescription: String = "영문, 숫자 혼용 8자 이상"
    static let validateNewPlaceholder: String = "새 비밀번호 확인"
    static let doneButtonTitle: String = "변경하기"
  }

  private enum Metric {
    static let verticalInset: CGFloat = 32.0
  }

  // MARK: - Properties

  // MARK: - UI Components

  private let scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
    return scrollView
  }()

  private lazy var currentPasswordTextField = self.makeTextField(
    placeholder: Typo.currentPlaceholder,
    description: Typo.currentDescription,
    isLastResponder: false)

  private lazy var newPasswordTextField = self.makeTextField(
    placeholder: Typo.newPlaceholder,
    description: Typo.newDescription,
    isLastResponder: false)

  private lazy var confirmNewPasswordTextField = self.makeTextField(
    placeholder: Typo.validateNewPlaceholder,
    isLastResponder: false)

  private let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 32.0
    return stackView
  }()

  private let doneButton: FavorLargeButton = {
    let button = FavorLargeButton(with: .main(Typo.doneButtonTitle))
    button.configurationUpdateHandler = { button in
      switch button.state {
      case .normal:
        button.configuration = FavorLargeButtonType.main(Typo.doneButtonTitle).configuration
      case .disabled:
        button.configuration = FavorLargeButtonType.gray(Typo.doneButtonTitle).configuration
      default:
        break
      }
    }
    button.isEnabled = false
    return button
  }()

  // MARK: - Life Cycle

  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    self.currentPasswordTextField.becomeFirstResponder()
  }

  // MARK: - Binding

  public func bind(reactor: AuthNewPasswordViewReactor) {
    // Action
    self.currentPasswordTextField.rx.text
      .orEmpty
      .map { Reactor.Action.oldPasswordTextFieldDidUpdate($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.currentPasswordTextField.rx.editingDidEndOnExit
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self, onNext: { owner, _ in
        owner.newPasswordTextField.becomeFirstResponder()
      })
      .disposed(by: self.disposeBag)

    self.newPasswordTextField.rx.text
      .orEmpty
      .map { Reactor.Action.newPasswordTextFieldDidUpdate($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.newPasswordTextField.rx.editingDidEndOnExit
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self, onNext: { owner, _ in
        owner.confirmNewPasswordTextField.becomeFirstResponder()
      })
      .disposed(by: self.disposeBag)

    self.confirmNewPasswordTextField.rx.text
      .orEmpty
      .map { Reactor.Action.confirmNewPasswordTextFieldDidUpdate($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.confirmNewPasswordTextField.rx.editingDidEndOnExit
      .map { Reactor.Action.nextFlowRequested }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.doneButton.rx.tap
      .map { Reactor.Action.nextFlowRequested }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.map { $0.isDoneButtonEnabled }
      .distinctUntilChanged()
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self, onNext: { owner, isEnabled in
        owner.doneButton.configurationUpdateHandler = { button in
          button.isEnabled = isEnabled
        }
      })
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.oldPasswordValidationResult }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .distinctUntilChanged()
      .skip(1)
      .drive(with: self, onNext: { owner, validationResult in
        switch validationResult {
        case .empty, .invalid:
          owner.currentPasswordTextField.updateMessageLabel(
            "비밀번호가 기존 비밀번호와 다릅니다.",
            state: .error
          )
        case .valid:
          owner.currentPasswordTextField.updateMessageLabel(
            Typo.currentDescription,
            state: .normal
          )
        }
      })
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.passwordValidationResult }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .distinctUntilChanged()
      .skip(1)
      .drive(with: self, onNext: { owner, validationResult in
        switch validationResult {
        case .empty, .invalid:
          owner.newPasswordTextField.updateMessageLabel(
            AuthValidationManager(type: .password).description(for: validationResult),
            state: .error
          )
        case .valid:
          owner.newPasswordTextField.updateMessageLabel(
            AuthValidationManager(type: .password).description(for: validationResult),
            state: .normal
          )
        }
      })
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.confirmPasswordValidationResult }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .distinctUntilChanged()
      .skip(1)
      .drive(with: self, onNext: { owner, validationResult in
        switch validationResult {
        case .empty, .invalid:
          owner.confirmNewPasswordTextField.updateMessageLabel(
            AuthValidationManager(type: .confirmPassword).description(for: validationResult),
            state: .error
          )
        case .valid:
          owner.confirmNewPasswordTextField.updateMessageLabel(
            AuthValidationManager(type: .confirmPassword).description(for: validationResult),
            state: .normal
          )
        }
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  // MARK: - UI Setups

  public override func setupLayouts() {
    [
      self.scrollView,
      self.doneButton
    ].forEach {
      self.view.addSubview($0)
    }

    self.scrollView.addSubview(self.stackView)

    [
      self.currentPasswordTextField,
      self.newPasswordTextField,
      self.confirmNewPasswordTextField
    ].forEach {
      self.stackView.addArrangedSubview($0)
    }
  }

  public override func setupConstraints() {
    self.scrollView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    self.stackView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(Metric.verticalInset)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
      make.width.equalToSuperview()
    }

    self.doneButton.snp.makeConstraints { make in
      make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top).offset(-Metric.verticalInset)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
    }
  }
}

// MARK: - Privates

private extension SettingsNewPasswordViewController {
  func makeTextField(
    placeholder: String,
    description: String? = nil,
    isLastResponder: Bool
  ) -> FavorTextField {
    let textField = FavorTextField()
    textField.placeholder = placeholder
    if let description {
      textField.updateMessageLabel(description)
    }
    textField.isSecureField = true
    textField.textField.keyboardType = .asciiCapable
    textField.textField.textContentType = .password
    textField.textField.returnKeyType = isLastResponder ? .done : .next
    return textField
  }
}
