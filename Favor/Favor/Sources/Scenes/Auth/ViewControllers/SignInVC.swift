//
//  SignInVC.swift
//  Favor
//
//  Created by 이창준 on 2023/01/12.
//

import UIKit

import ReactorKit
import SnapKit
import Then

final class SignInViewController: BaseViewController, View {
  typealias Reactor = SignInReactor
  
  // MARK: - Constants
  
  // MARK: - Properties
  
  // MARK: - UI Components
  
  private lazy var emailTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.placeholder = "이메일"
    textField.keyboardType = .emailAddress
    textField.returnKeyType = .next
    textField.enablesReturnKeyAutomatically = true
    textField.becomeFirstResponder()
    return textField
  }()
  
  private lazy var pwTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.placeholder = "비밀번호"
    textField.isSecureTextEntry = true
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
  
  // TODO: - plain 버튼으로 변경
  private lazy var forgotEmailButton: UIButton = {
    let button = UIButton()
    button.setTitle("이메일 찾기", for: .normal)
    button.setTitleColor(.favorColor(.detail), for: .normal)
    return button
  }()
  
  private lazy var forgotPWButton: UIButton = {
    let button = UIButton()
    button.setTitle("비밀번호 찾기", for: .normal)
    button.setTitleColor(.favorColor(.detail), for: .normal)
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
    //
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
