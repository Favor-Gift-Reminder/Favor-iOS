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
  
  // MARK: - Properties
  
  // MARK: - UI Components
  
  private lazy var emailTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.placeholder = "이메일"
    textField.keyboardType = .emailAddress
    textField.autocapitalizationType = .none
    textField.returnKeyType = .next
    textField.enablesReturnKeyAutomatically = true
    return textField
  }()
  
  private lazy var pwTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.placeholder = "비밀번호"
    textField.isSecureTextEntry = true
    textField.enablesReturnKeyAutomatically = true
    textField.returnKeyType = .done
    return textField
  }()
  
  private lazy var loginButton: LargeFavorButton = {
    let button = LargeFavorButton(with: .white, title: "시작하기")
    return button
  }()
  
  private lazy var vStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 72.0
    stackView.addArrangedSubview(self.emailTextField)
    stackView.addArrangedSubview(self.pwTextField)
    stackView.addArrangedSubview(self.loginButton)
    return stackView
  }()
  
  private lazy var forgotEmailButton: PlainFavorButton = {
    let button = PlainFavorButton(.large, icon: .right, title: "이메일 찾기")
    return button
  }()
  
  private lazy var forgotPWButton: PlainFavorButton = {
    let button = PlainFavorButton(.large, icon: .right, title: "비밀번호 찾기")
    return button
  }()
  
  private lazy var hStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 16.0
    stackView.addArrangedSubview(self.forgotEmailButton)
    stackView.addArrangedSubview(self.forgotPWButton)
    return stackView
  }()
  
  // MARK: - Life Cycle
  
  // MARK: - Binding
  
  func bind(reactor: SignInReactor) {
    // Action
    Observable.just(())
      .bind(with: self, onNext: { owner, _ in
        owner.emailTextField.becomeFirstResponder()
      })
      .disposed(by: self.disposeBag)
    
    self.emailTextField.rx.controlEvent(.editingDidEndOnExit)
      .bind(with: self, onNext: { owner, _ in
        owner.pwTextField.becomeFirstResponder()
      })
      .disposed(by: self.disposeBag)
    
    self.pwTextField.rx.controlEvent(.editingDidEndOnExit)
      .map { Reactor.Action.returnKeyboardTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.loginButton.rx.tap
      .map { Reactor.Action.loginButtonTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
  }
  
  // MARK: - Functions
  
  // MARK: - UI Setups
  
  override func setupLayouts() {
    [
      self.vStack,
      self.hStack
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.vStack.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(56)
      make.leading.trailing.equalTo(self.view.layoutMarginsGuide)
    }
    
    self.hStack.snp.makeConstraints { make in
      make.top.equalTo(self.vStack.snp.bottom).offset(32)
      make.centerX.equalToSuperview()
    }
  }
  
}
