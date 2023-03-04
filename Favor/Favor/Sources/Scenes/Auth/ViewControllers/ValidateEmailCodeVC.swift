//
//  ValidateEmailCodeVC.swift
//  Favor
//
//  Created by 이창준 on 2023/03/04.
//

import UIKit

import ReactorKit
import RxCocoa
import SnapKit

final class ValidateEmailCodeViewController: BaseViewController, View {

  // MARK: - Constants

  private enum Metric {
    static let topSpacing = 56.0
  }

  // MARK: - Properties

  // MARK: - UI Components

  private lazy var emailCodeTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.placeholder = "인증 코드"
    textField.updateMessageLabel("example@naver.com으로 전송된 6자리 코드를 입력하세요.")
    textField.textField.keyboardType = .asciiCapableNumberPad
    return textField
  }()

  private lazy var nextButton: LargeFavorButton = {
    let button = LargeFavorButton(with: .main("다음"))
    button.isEnabled = false
    return button
  }()

  // MARK: - Life Cycle

  // MARK: - Binding

  func bind(reactor: ValidateEmailCodeViewReactor) {
    // Action
    Observable.just(())
      .asDriver(onErrorRecover: { _ in return .never()})
      .drive(with: self, onNext: { owner, _ in
        owner.emailCodeTextField.becomeFirstResponder()
      })
      .disposed(by: self.disposeBag)

    self.emailCodeTextField.rx.text
      .orEmpty
      .map { $0.count }
      .asDriver(onErrorRecover: { _ in return .never()})
      .drive(with: self, onNext: { owner, count in
        let currentInput = owner.emailCodeTextField.textField.text
        if count > 6 {
          owner.emailCodeTextField.textField.text = String(currentInput?.dropLast() ?? "")
        }
      })
      .disposed(by: self.disposeBag)

    self.emailCodeTextField.rx.text
      .orEmpty
      .do(onNext: {
        self.nextButton.isEnabled = $0.count == 6 ? true : false
      })
      .map { Reactor.Action.emailCodeTextFieldDidUpdate($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.nextButton.rx.tap
      .map { Reactor.Action.nextFlowRequested }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // State
    reactor.state.map { $0.email }
      .asDriver(onErrorRecover: { _ in return .never()})
      .drive(with: self, onNext: { owner, email in
        owner.emailCodeTextField.updateMessageLabel("\(email)으로 전송된 6자리 코드를 입력하세요.")
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  // MARK: - UI Setups

  override func setupStyles() {
    super.setupStyles()
  }

  override func setupLayouts() {
    [
      self.emailCodeTextField,
      self.nextButton
    ].forEach {
      self.view.addSubview($0)
    }
  }

  override func setupConstraints() {
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
