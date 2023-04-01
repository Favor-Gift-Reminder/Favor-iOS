//
//  SignUpVC.swift
//  Favor
//
//  Created by 이창준 on 2023/01/16.
//

import UIKit

import FavorKit
import ReactorKit
import RxCocoa
import RxGesture
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
//    textField.textField.textContentType = .newPassword
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
//    textField.textField.textContentType = .newPassword
    textField.textField.returnKeyType = .done
    return textField
  }()
  
  private lazy var nextButton: FavorLargeButton = {
    let button = FavorLargeButton(with: .main("다음"))
    button.configurationUpdateHandler = { button in
      switch button.state {
      case .normal:
        button.configuration = LargeFavorButtonType.main("다음").configuration
      case .disabled:
        button.configuration = LargeFavorButtonType.gray("다음").configuration
      default:
        break
      }
    }
    button.isEnabled = false
    return button
  }()
  
  private lazy var textFieldStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = Metric.textFieldSpacing
    return stackView
  }()
  
  // MARK: - Life Cycle

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.emailTextField.becomeFirstResponder()
  }
  
  // MARK: - Binding

  func bind(reactor: SignUpViewReactor) {
    // Action
    Observable.just(())
      .bind(with: self, onNext: { owner, _ in
        owner.emailTextField.becomeFirstResponder()
      })
      .disposed(by: self.disposeBag)

    // Email TextField
    self.emailTextField.rx.text
      .orEmpty
      .distinctUntilChanged()
      .map { Reactor.Action.emailTextFieldDidUpdate($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.emailTextField.rx.editingDidBegin
      .bind(with: self, onNext: { owner, _ in
        owner.scrollView.scroll(to: .zero)
      })
      .disposed(by: self.disposeBag)
    
    self.emailTextField.rx.editingDidEndOnExit
      .bind(with: self, onNext: { owner, _ in
        owner.pwTextField.becomeFirstResponder()
        owner.scrollView.scroll(to: self.pwTextField.frame.maxY - Metric.topSpacing)
      })
      .disposed(by: self.disposeBag)

    // Password TextField
    self.pwTextField.rx.text
      .orEmpty
      .distinctUntilChanged()
      .map { Reactor.Action.passwordTextFieldDidUpdate($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.pwTextField.rx.editingDidBegin
      .bind(with: self, onNext: { owner, _ in
        owner.scrollView.scroll(to: owner.pwTextField.frame.maxY - Metric.topSpacing)
      })
      .disposed(by: self.disposeBag)
    
    self.pwTextField.rx.editingDidEndOnExit
      .bind(with: self, onNext: { owner, _ in
        owner.pwValidateTextField.becomeFirstResponder()
      })
      .disposed(by: self.disposeBag)

    // Password Validation TextField
    self.pwValidateTextField.rx.text
      .orEmpty
      .distinctUntilChanged()
      .map { Reactor.Action.confirmPasswordTextFieldDidUpdate($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.pwValidateTextField.rx.editingDidBegin
      .bind(with: self, onNext: { owner, _ in
        owner.scrollView.scroll(to: owner.pwTextField.frame.maxY - Metric.topSpacing)
      })
      .disposed(by: self.disposeBag)
    
    self.pwValidateTextField.rx.editingDidEndOnExit
      .do(onNext: { [weak self] _ in
        self?.scrollView.scroll(to: .zero)
      })
      .delay(.milliseconds(500), scheduler: MainScheduler.instance)
      .map { Reactor.Action.nextFlowRequested }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.nextButton.rx.tap
      .map { Reactor.Action.nextFlowRequested }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.scrollView.rx.tapGesture()
      .when(.recognized)
      .asDriver(onErrorRecover: { _ in return .never()})
      .drive(with: self, onNext: {  owner, _ in
        owner.view.endEditing(true)
        owner.scrollView.scroll(to: .zero)
      })
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
    
    reactor.state.map { $0.isLoading }
      .bind(to: self.rx.isLoading)
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
      self.emailTextField,
      self.pwTextField,
      self.pwValidateTextField
    ].forEach {
      self.textFieldStack.addArrangedSubview($0)
    }

    self.scrollView.addSubview(self.textFieldStack)
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
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
      make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top).offset(-Metric.bottomSpacing)
    }
  }
}
