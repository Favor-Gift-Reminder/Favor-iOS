//
//  FindPasswordVC.swift
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

final class FindPasswordViewController: BaseViewController, View {

  // MARK: - Constants

  private enum Metric {
    static let topSpacing = 56.0
  }

  // MARK: - Properties

  // MARK: - UI Components

  private lazy var textField: FavorTextField = {
    let textField = FavorTextField()
    textField.placeholder = "이메일"
    textField.updateMessageLabel("가입 시 사용했던 이메일을 입력해주세요.")
    textField.textField.keyboardType = .emailAddress
    textField.textField.autocorrectionType = .no
    textField.textField.enablesReturnKeyAutomatically = true
    return textField
  }()

  private lazy var nextButton: FavorLargeButton = {
    let button = FavorLargeButton(with: .main("다음"))
    return button
  }()

  // MARK: - Life Cycle

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.textField.becomeFirstResponder()
  }

  // MARK: - Binding

  func bind(reactor: FindPasswordViewReactor) {
    // Action
    self.textField.rx.text
      .orEmpty
      .distinctUntilChanged()
      .map { Reactor.Action.emailTextFieldDidUpdate($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.textField.rx.editingDidEndOnExit
      .do(onNext: {
        self.textField.resignFirstResponder()
      })
      .delay(.milliseconds(500), scheduler: MainScheduler.instance)
      .map { Reactor.Action.nextFlowRequested }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.nextButton.rx.tap
      .do(onNext: {
        self.textField.resignFirstResponder()
      })
      .delay(.milliseconds(500), scheduler: MainScheduler.instance)
      .map { Reactor.Action.nextFlowRequested }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.view.rx.tapGesture()
      .when(.recognized)
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: {  owner, _ in
        owner.view.endEditing(true)
      })
      .disposed(by: self.disposeBag)

    // State
    reactor.state.map { $0.isNextButtonEnabled }
      .bind(with: self, onNext: { owner, isEnabled in
        owner.nextButton.isEnabled = isEnabled
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
      self.textField,
      self.nextButton
    ].forEach {
      self.view.addSubview($0)
    }
  }

  override func setupConstraints() {
    self.textField.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide).inset(Metric.topSpacing)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
    }

    self.nextButton.snp.makeConstraints { make in
      make.top.equalTo(self.textField.snp.bottom).offset(Metric.topSpacing)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
    }
  }
}
