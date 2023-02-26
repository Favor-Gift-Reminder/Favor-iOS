//
//  SignUpVC.swift
//  Favor
//
//  Created by 이창준 on 2023/01/16.
//

import UIKit

import ReactorKit
import RxCocoa
import RxKeyboard
import SnapKit

final class SignUpViewController: BaseViewController, View {
  
  // MARK: - Constants

  private enum Metric {
    static let topSpacing = 56.0
    static let textFieldSpacing = 32.0
    static let bottomSpacing = 32.0
  }
  
  // MARK: - Properties
  
  // MARK: - UI Components

  private lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
//    scrollView.isPagingEnabled = false
//    scrollView.isScrollEnabled = false
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
    return scrollView
  }()
  
  private lazy var emailTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.placeholder = "이메일"
    textField.updateMessageLabel(
      AuthValidationManager(type: .email).description(for: .empty),
      state: .normal,
      animated: false
    )
    textField.textField.keyboardType = .emailAddress
    textField.textField.textContentType = .emailAddress
    textField.textField.returnKeyType = .next
    return textField
  }()
  
  private lazy var pwTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.placeholder = "비밀번호"
    textField.updateMessageLabel(
      AuthValidationManager(type: .password).description(for: .empty),
      state: .normal,
      animated: false
    )
    textField.isSecureField = true
    textField.textField.textContentType = .newPassword
    textField.textField.returnKeyType = .next
    return textField
  }()
  
  private lazy var pwValidateTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.placeholder = "비밀번호 확인"
    textField.updateMessageLabel(
      AuthValidationManager(type: .confirmPassword).description(for: .empty),
      state: .normal,
      animated: false
    )
    textField.isSecureField = true
    textField.textField.keyboardType = .asciiCapable
    textField.textField.textContentType = .password
    textField.textField.returnKeyType = .done
    return textField
  }()
  
  private lazy var nextButton: LargeFavorButton = {
    let button = LargeFavorButton(with: .main("다음"))
    button.isEnabled = false
    return button
  }()
  
  private lazy var textFieldStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = Metric.textFieldSpacing
    [
      self.emailTextField,
      self.pwTextField,
      self.pwValidateTextField
    ].forEach {
      stackView.addArrangedSubview($0)
    }
    return stackView
  }()
  
  // MARK: - Life Cycle
  
  // MARK: - Binding

  func bind(reactor: SignUpViewReactor) {
    // Keyboard
    RxKeyboard.instance.visibleHeight
      .skip(1)
      .drive(with: self, onNext: { owner, visibleHeight in
        owner.nextButton.snp.updateConstraints { make in
          make.bottom.equalToSuperview().offset(-visibleHeight - Metric.bottomSpacing)
        }
        owner.view.layoutIfNeeded()
      })
      .disposed(by: self.disposeBag)

    // Action
    Observable.just(())
      .bind(with: self, onNext: { owner, _ in
        owner.emailTextField.becomeFirstResponder()
      })
      .disposed(by: self.disposeBag)
    
    self.emailTextField.rx.text
      .orEmpty
      .distinctUntilChanged()
      .map { Reactor.Action.emailTextFieldDidUpdate($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.emailTextField.rx.editingDidEndOnExit
      .bind(with: self, onNext: { owner, _ in
        owner.pwTextField.becomeFirstResponder()
      })
      .disposed(by: self.disposeBag)
    
    self.pwTextField.rx.text
      .orEmpty
      .distinctUntilChanged()
      .map { Reactor.Action.passwordTextFieldDidUpdate($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.pwTextField.rx.editingDidEndOnExit
      .bind(with: self, onNext: { owner, _ in
        owner.pwValidateTextField.becomeFirstResponder()
      })
      .disposed(by: self.disposeBag)
    
    self.pwValidateTextField.rx.text
      .orEmpty
      .distinctUntilChanged()
      .map { Reactor.Action.confirmPasswordTextFieldDidUpdate($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.pwValidateTextField.rx.editingDidEndOnExit
      .map { Reactor.Action.nextFlowRequested }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.nextButton.rx.tap
      .map { Reactor.Action.nextFlowRequested }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.map { $0.emailValidationResult }
      .asDriver(onErrorJustReturn: .valid)
      .distinctUntilChanged()
      .skip(1)
      .drive(with: self, onNext: { owner, validationResult in
        switch validationResult {
        case .empty, .invalid:
          owner.emailTextField.updateMessageLabel(
            AuthValidationManager(type: .email).description(for: validationResult),
            state: .error
          )
        case .valid:
          owner.emailTextField.updateMessageLabel(
            AuthValidationManager(type: .email).description(for: validationResult),
            state: .normal
          )
        }
      })
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.passwordValidationResult }
      .asDriver(onErrorJustReturn: .valid)
      .distinctUntilChanged()
      .skip(1)
      .drive(with: self, onNext: { owner, validationResult in
        switch validationResult {
        case .empty, .invalid:
          owner.pwTextField.updateMessageLabel(
            AuthValidationManager(type: .password).description(for: validationResult),
            state: .error
          )
        case .valid:
          owner.pwTextField.updateMessageLabel(
            AuthValidationManager(type: .password).description(for: validationResult),
            state: .normal
          )
        }
      })
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.confirmPasswordValidationResult }
      .asDriver(onErrorJustReturn: .valid)
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
    
    reactor.state.map { $0.isNextButtonEnabled }
      .asDriver(onErrorJustReturn: false)
      .distinctUntilChanged()
      .drive(with: self, onNext: { owner, isButtonEnabled in
        owner.nextButton.configurationUpdateHandler = { button in
          button.isEnabled = (isButtonEnabled == true)
        }
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
      self.scrollView,
      self.nextButton
    ].forEach {
      self.view.addSubview($0)
    }

    [
      self.textFieldStack
    ].forEach {
      self.scrollView.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.scrollView.snp.makeConstraints { make in
      make.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
    }

    self.textFieldStack.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(Metric.topSpacing)
      make.directionalHorizontalEdges.equalToSuperview()
      make.width.equalToSuperview()
    }

    self.nextButton.snp.makeConstraints { make in
      make.bottom.equalToSuperview().offset(-Metric.bottomSpacing)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
    }
  }
}
