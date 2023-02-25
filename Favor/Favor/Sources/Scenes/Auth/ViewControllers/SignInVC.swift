//
//  SignInVC.swift
//  Favor
//
//  Created by 이창준 on 2023/01/12.
//

import UIKit

import ReactorKit
import RxCocoa
import SnapKit
import Then

final class SignInViewController: BaseViewController, View {
  
  // MARK: - Constants

  private enum Metric {
    static let sectionSpacing = 56.0
  }
  
  // MARK: - Properties
  
  // MARK: - UI Components
  
  private lazy var emailTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.placeholder = "이메일"
    textField.textField.keyboardType = .emailAddress
    textField.textField.returnKeyType = .next
    return textField
  }()
  
  private lazy var passwordTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.placeholder = "비밀번호"
    textField.isSecureField = true
    textField.textField.returnKeyType = .done
    return textField
  }()

  private lazy var textFieldStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 32
    return stackView
  }()
  
  private lazy var signInButton = LargeFavorButton(with: .main("로그인"))
  
  private lazy var findPasswordButton = PlainFavorButton(with: .logIn("비밀번호 찾기"))

  private lazy var buttonStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 32
    stackView.contentMode = .center
    return stackView
  }()
  
  // MARK: - Life Cycle
  
  // MARK: - Binding
  
  func bind(reactor: SignInReactor) {
    // Action
    Observable.just(())
      .asDriver(onErrorJustReturn: ())
      .drive(with: self, onNext: { owner, _ in
        owner.emailTextField.textField.becomeFirstResponder()
      })
      .disposed(by: self.disposeBag)

    self.emailTextField.rx.editingDidEndOnExit
      .bind(with: self, onNext: { owner, _ in
        owner.passwordTextField.textField.becomeFirstResponder()
      })
      .disposed(by: self.disposeBag)
    
    self.passwordTextField.rx.editingDidEndOnExit
      .asDriver(onErrorJustReturn: ())
      .drive(with: self, onNext: { owner, _ in
        owner.passwordTextField.textField.resignFirstResponder()
      })
      .disposed(by: self.disposeBag)
    
    self.signInButton.rx.tap
      .map { Reactor.Action.signInButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.findPasswordButton.rx.tap
      .map { Reactor.Action.findPasswordButtonDidTap }
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
    [
      self.emailTextField,
      self.passwordTextField
    ].forEach {
      self.textFieldStack.addArrangedSubview($0)
    }

    [
      self.signInButton,
      self.findPasswordButton
    ].forEach {
      self.buttonStack.addArrangedSubview($0)
    }

    [
      self.textFieldStack,
      self.buttonStack
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.textFieldStack.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(Metric.sectionSpacing)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
    }

    self.buttonStack.snp.makeConstraints { make in
      make.top.equalTo(self.textFieldStack.snp.bottom).offset(Metric.sectionSpacing)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
    }
  }
  
}
