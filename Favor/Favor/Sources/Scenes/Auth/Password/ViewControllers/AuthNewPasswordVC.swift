//
//  AuthNewPasswordVC.swift
//  Favor
//
//  Created by 이창준 on 2023/03/04.
//

import UIKit

import FavorKit
import ReactorKit
import RxCocoa
import RxGesture
import SnapKit

public final class AuthNewPasswordViewController: BaseViewController, View {

  // MARK: - Constants

  private enum Metric {
    static let topSpacing = 56.0
    static let bottomSpacing = 32.0
  }

  // MARK: - Properties

  // MARK: - UI Components

  private let scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
    return scrollView
  }()

  private let newPasswordTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.placeholder = "새 비밀번호"
    textField.updateMessageLabel("영문, 숫자 혼용 6자 이상")
    textField.isSecureField = true
    textField.textField.keyboardType = .asciiCapable
    textField.textField.textContentType = .newPassword
    textField.textField.returnKeyType = .next
    return textField
  }()

  private let pwValidateTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.placeholder = "새 비밀번호 확인"
    textField.isSecureField = true
    textField.textField.keyboardType = .asciiCapable
    textField.textField.textContentType = .newPassword
    textField.textField.returnKeyType = .done
    return textField
  }()

  private let textFieldStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 32
    return stackView
  }()

  private let doneButton: FavorLargeButton = {
    let button = FavorLargeButton(with: .main("변경하기"))
    button.configurationUpdateHandler = { button in
      switch button.state {
      case .normal:
        button.configuration = FavorLargeButtonType.main("다음").configuration
      case .disabled:
        button.configuration = FavorLargeButtonType.gray("다음").configuration
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
    self.newPasswordTextField.becomeFirstResponder()
  }

  // MARK: - Binding

  public func bind(reactor: AuthNewPasswordViewReactor) {
    // Action
    self.newPasswordTextField.rx.text
      .orEmpty
      .map { Reactor.Action.newPasswordTextFieldDidUpdate($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.newPasswordTextField.rx.editingDidEndOnExit
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, _ in
        owner.pwValidateTextField.becomeFirstResponder()
      })
      .disposed(by: self.disposeBag)

    self.pwValidateTextField.rx.text
      .orEmpty
      .map { Reactor.Action.confirmNewPasswordTextFieldDidUpdate($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.pwValidateTextField.rx.editingDidEndOnExit
      .do(onNext: { _ in
        self.pwValidateTextField.resignFirstResponder()
      })
      .map { Reactor.Action.nextFlowRequested }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.scrollView.rx.tapGesture()
      .when(.recognized)
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: {  owner, _ in
        owner.view.endEditing(true)
        owner.scrollView.scroll(to: .zero)
      })
      .disposed(by: self.disposeBag)

    // State
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
          owner.pwValidateTextField.updateMessageLabel(
            AuthValidationManager(type: .confirmPassword).description(for: validationResult),
            state: .error
          )
        case .valid:
          owner.pwValidateTextField.updateMessageLabel(
            AuthValidationManager(type: .confirmPassword).description(for: validationResult),
            state: .normal
          )
        }
      })
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.isDoneButtonEnabled }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, isEnabled in
        owner.doneButton.isEnabled = isEnabled
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  // MARK: - UI Setups

  public override func setupStyles() {
    super.setupStyles()
  }

  public override func setupLayouts() {
    [
      self.scrollView,
      self.doneButton
    ].forEach {
      self.view.addSubview($0)
    }

    [
      self.newPasswordTextField,
      self.pwValidateTextField
    ].forEach {
      self.textFieldStackView.addArrangedSubview($0)
    }

    self.scrollView.addSubview(self.textFieldStackView)
  }

  public override func setupConstraints() {
    self.scrollView.snp.makeConstraints { make in
      make.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
    }

    self.textFieldStackView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(Metric.topSpacing)
      make.directionalHorizontalEdges.equalToSuperview()
      make.width.equalToSuperview()
    }

    self.doneButton.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
      make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top).offset(-Metric.bottomSpacing)
    }
  }
}
