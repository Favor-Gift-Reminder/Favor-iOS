//
//  SignUpVC.swift
//  Favor
//
//  Created by 이창준 on 2023/01/16.
//

import UIKit

import ReactorKit
import SnapKit

final class SignUpViewController: BaseViewController, View {
  typealias Reactor = SignUpReactor
  
  // MARK: - Constants
  
  // MARK: - Properties
  
  // MARK: - UI Components
  
  private lazy var emailTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.delegate = self
    textField.placeholder = "이메일"
    textField.updateMessage("실제 사용하는 이메일을 입력해주세요.", for: .info)
    textField.keyboardType = .emailAddress
    textField.autocapitalizationType = .none
    textField.becomeFirstResponder()
    return textField
  }()
  
  private lazy var pwTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.delegate = self
    textField.placeholder = "비밀번호"
    textField.updateMessage("영문, 숫자 혼용 8자 이상", for: .info)
    textField.keyboardType = .asciiCapable
    textField.autocapitalizationType = .none
    return textField
  }()
  
  private lazy var pwValidateTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.delegate = self
    textField.placeholder = "비밀번호 확인"
    textField.keyboardType = .asciiCapable
    textField.autocapitalizationType = .none
    return textField
  }()
  
  private lazy var nextButton: LargeFavorButton = {
    let button = LargeFavorButton(with: .white, title: "다음")
    button.isEnabled = false
    return button
  }()
  
  private lazy var vStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 72.0
    [
      self.emailTextField,
      self.pwTextField,
      self.pwValidateTextField,
      self.nextButton
    ].forEach {
      stackView.addArrangedSubview($0)
    }
    return stackView
  }()
  
  // MARK: - Life Cycle
  
  // MARK: - Binding
  
  func bind(reactor: SignUpReactor) {
    // Action
    self.emailTextField.rx.text
      .orEmpty
      .distinctUntilChanged()
      .map { Reactor.Action.emailTextFieldUpdate($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.pwTextField.rx.text
      .orEmpty
      .distinctUntilChanged()
      .map { Reactor.Action.passwordTextFieldUpdate($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.pwValidateTextField.rx.text
      .orEmpty
      .distinctUntilChanged()
      .map { Reactor.Action.checkPasswordTextFieldUpdate($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.nextButton.rx.tap
      .map { Reactor.Action.nextButtonTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.asObservable()
      .map { $0.isEmailValid }
      .distinctUntilChanged()
      .skip(1)
      .subscribe(onNext: { emailValidate in
        switch emailValidate {
        case .empty, .invalid:
          self.emailTextField.updateMessage(emailValidate.description, for: .error)
        case .valid:
          self.emailTextField.updateMessage(nil, for: .info)
        }
      })
      .disposed(by: self.disposeBag)
    
    reactor.state.asObservable()
      .map { $0.isPasswordValid }
      .distinctUntilChanged()
      .skip(1)
      .subscribe(onNext: { passwordValidate in
        switch passwordValidate {
        case .empty, .invalid:
          self.pwTextField.updateMessage(passwordValidate.description, for: .error)
        case .valid:
          self.pwTextField.updateMessage(nil, for: .info)
        }
      })
      .disposed(by: self.disposeBag)
    
    reactor.state.asObservable()
      .map { $0.isPasswordIdentical }
      .distinctUntilChanged()
      .skip(1)
      .subscribe(onNext: { isPasswordIdentical in
        switch isPasswordIdentical {
        case .empty, .different:
          self.pwValidateTextField.updateMessage(isPasswordIdentical.description, for: .error)
        case .identical:
          self.pwValidateTextField.updateMessage(nil, for: .info)
        }
      })
      .disposed(by: self.disposeBag)
    
    reactor.state.asObservable()
      .map { $0.isNextButtonEnabled }
      .distinctUntilChanged()
      .subscribe(onNext: { isButtonEnabled in
        DispatchQueue.main.async {
          self.nextButton.configurationUpdateHandler = { button in
            button.isEnabled = (isButtonEnabled == true)
          }
        }
      })
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Functions
  
  // MARK: - UI Setups
  
  override func setupLayouts() {
    [self.vStack].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    
    self.vStack.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(56)
      make.leading.trailing.equalTo(self.view.layoutMarginsGuide)
    }
  }
  
}

// MARK: - TextField

extension SignUpViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == self.emailTextField {
      self.pwTextField.becomeFirstResponder()
    } else if textField == self.pwTextField {
      self.pwValidateTextField.becomeFirstResponder()
    } else {
      self.pwValidateTextField.resignFirstResponder()
    }
    return true
  }
  
}
