//
//  AuthValidateEmailVC.swift
//  Favor
//
//  Created by 이창준 on 2023/03/04.
//

import UIKit

import FavorKit
import ReactorKit
import RxCocoa
import SnapKit

public final class AuthValidateEmailViewController: BaseViewController, View {

  // MARK: - Constants

  private enum Metric {
    static let topSpacing = 56.0
  }

  // MARK: - Properties

  // MARK: - UI Components

  private let emailCodeTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.placeholder = "인증 코드"
    textField.updateMessageLabel("example@naver.com으로 전송된 6자리 코드를 입력하세요.")
    textField.textField.keyboardType = .asciiCapableNumberPad
    textField.textField.textContentType = .oneTimeCode
    return textField
  }()

  private let nextButton: FavorLargeButton = {
    let button = FavorLargeButton(with: .main("다음"))
    button.isEnabled = false
    return button
  }()

  // MARK: - Life Cycle

  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.emailCodeTextField.becomeFirstResponder()
  }

  // MARK: - Binding

  public func bind(reactor: AuthValidateEmailViewReactor) {
    // Action
    self.emailCodeTextField.rx.text
      .orEmpty
      .distinctUntilChanged()
      .observe(on: MainScheduler.asyncInstance)
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, code in
        let currentInput = owner.emailCodeTextField.textField.text
        let trimmedCurrentInput = currentInput?.trimmingCharacters(in: .whitespacesAndNewlines)
        if code.count > 6 {
          owner.emailCodeTextField.textField.text = String(trimmedCurrentInput?.dropLast() ?? "")
        }
        if code.count == 6 {
          owner.emailCodeTextField.resignFirstResponder()
          DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            reactor.action.onNext(.nextFlowRequested)
          }
        }
      })
      .disposed(by: self.disposeBag)

    self.nextButton.rx.tap
      .delay(.milliseconds(500), scheduler: MainScheduler.instance)
      .map { Reactor.Action.nextFlowRequested }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // State
    reactor.state.map { $0.email }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, email in
        owner.emailCodeTextField.updateMessageLabel("\(email)으로 전송된 6자리 코드를 입력하세요.")
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
      self.emailCodeTextField,
      self.nextButton
    ].forEach {
      self.view.addSubview($0)
    }
  }

  public override func setupConstraints() {
    self.emailCodeTextField.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide).inset(Metric.topSpacing)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
    }

    self.nextButton.snp.makeConstraints { make in
      make.top.equalTo(self.emailCodeTextField.snp.bottom).offset(56)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
    }
  }
}
