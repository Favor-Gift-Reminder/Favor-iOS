//
//  NewPasswordVC.swift
//  Favor
//
//  Created by 이창준 on 2023/03/04.
//

import UIKit

import ReactorKit
import RxCocoa
import SnapKit

final class NewPasswordViewController: BaseViewController, View {

  // MARK: - Constants

  private enum Metric {
    static let topSpacing = 56.0
    static let bottomSpacing = 32.0
  }

  // MARK: - Properties

  // MARK: - UI Components

  private lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
    return scrollView
  }()

  private lazy var newPasswordTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.placeholder = "새 비밀번호"
    textField.updateMessageLabel("영문, 숫자 혼용 6자 이상")
    textField.isSecureField = true
    textField.textField.keyboardType = .asciiCapable
    textField.textField.textContentType = .newPassword
    textField.textField.returnKeyType = .next
    return textField
  }()

  private lazy var pwValidateTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.placeholder = "새 비밀번호 확인"
    textField.isSecureField = true
    textField.textField.keyboardType = .asciiCapable
    textField.textField.textContentType = .newPassword
    textField.textField.returnKeyType = .done
    return textField
  }()

  private lazy var textFieldStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 32
    return stackView
  }()

  private lazy var doneButton: LargeFavorButton = {
    let button = LargeFavorButton(with: .main("변경하기"))
    button.isEnabled = false
    return button
  }()

  // MARK: - Life Cycle

  // MARK: - Binding

  func bind(reactor: NewPasswordViewReactor) {
    // Action
    Observable.just(())
      .asDriver(onErrorRecover: { _ in return .never()})
      .drive(with: self, onNext: { owner, _ in
        owner.newPasswordTextField.becomeFirstResponder()
      })
      .disposed(by: self.disposeBag)

    self.newPasswordTextField.rx.editingDidEndOnExit
      .asDriver(onErrorRecover: { _ in return .never()})
      .drive(with: self, onNext: { owner, _ in
        owner.pwValidateTextField.becomeFirstResponder()
      })
      .disposed(by: self.disposeBag)

    self.pwValidateTextField.rx.editingDidEndOnExit
      .do(onNext: { _ in
        self.pwValidateTextField.resignFirstResponder()
      })
      .map { Reactor.Action.nextFlowRequested }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // State

  }

  // MARK: - Functions

  // MARK: - UI Setups

  override func setupStyles() {
    super.setupStyles()
  }

  override func setupLayouts() {
    self.view.addSubview(self.scrollView)

    [
      self.textFieldStackView,
      self.doneButton
    ].forEach {
      self.scrollView.addSubview($0)
    }

    [
      self.newPasswordTextField,
      self.pwValidateTextField
    ].forEach {
      self.textFieldStackView.addArrangedSubview($0)
    }
  }

  override func setupConstraints() {
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
      make.bottom.equalToSuperview().offset(-Metric.bottomSpacing)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
    }
  }
}
