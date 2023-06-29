//
//  AuthSignUpVC.swift
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

public final class AuthSignUpViewController: BaseViewController, View {
  
  // MARK: - Constants

  private enum Metric {
    static let topSpacing = 56.0
    static let textFieldSpacing = 32.0
    static let bottomSpacing = 32.0
  }

  private enum Typo {
    static let emailPlaceholder: String = "이메일"
    static let passwordPlaceholder: String = "비밀번호"
    static let passwordValidatePlaceholder: String = "비밀번호 확인"
    static let nextButtonTitle: String = "다음"
  }

  // MARK: - Properties
  
  // MARK: - UI Components

  private let scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
    return scrollView
  }()
  
  private let emailTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.placeholder = Typo.emailPlaceholder
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
    textField.placeholder = Typo.passwordPlaceholder
    textField.updateMessageLabel(
      AuthValidationManager(type: .password).description(for: .empty),
      state: .normal,
      animated: false
    )
    textField.isSecureField = true
    textField.textField.returnKeyType = .next
    return textField
  }()
  
  private let pwValidateTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.placeholder = Typo.passwordValidatePlaceholder
    textField.updateMessageLabel(
      AuthValidationManager(type: .confirmPassword).description(for: .empty),
      state: .normal,
      animated: false
    )
    textField.isSecureField = true
    textField.textField.returnKeyType = .done
    return textField
  }()
  
  private let nextButton: FavorLargeButton = {
    let button = FavorLargeButton(with: .main(Typo.nextButtonTitle))
    button.configurationUpdateHandler = { button in
      switch button.state {
      case .normal:
        button.configuration = FavorLargeButtonType.main(Typo.nextButtonTitle).configuration
      case .disabled:
        button.configuration = FavorLargeButtonType.gray(Typo.nextButtonTitle).configuration
      default:
        break
      }
    }
    button.isEnabled = false
    return button
  }()
  
  private let textFieldStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = Metric.textFieldSpacing
    return stackView
  }()
  
  // MARK: - Life Cycle

  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.emailTextField.becomeFirstResponder()
  }
  
  // MARK: - Binding

  public func bind(reactor: AuthSignUpViewReactor) {
    // Action
    self.rx.viewDidLoad
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
      .map { Reactor.Action.nextButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.nextButton.rx.tap
      .map { Reactor.Action.nextButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.scrollView.rx.tapGesture()
      .when(.recognized)
      .asDriver(onErrorRecover: { _ in return .never() })
      .drive(with: self, onNext: { owner, _ in
        owner.view.endEditing(true)
        owner.scrollView.scroll(to: .zero)
      })
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.map { $0.toastMessage }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self, onNext: { owner, message in
        owner.presentToast(message, duration: .short)
      })
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.emailValidationResult }
      .asDriver(onErrorRecover: { _ in return .never() })
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
      .asDriver(onErrorRecover: { _ in return .never() })
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
      .asDriver(onErrorRecover: { _ in return .never() })
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
      .asDriver(onErrorRecover: { _ in return .never()})
      .distinctUntilChanged()
      .drive(with: self, onNext: { owner, isButtonEnabled in
        owner.nextButton.configurationUpdateHandler = { button in
          button.isEnabled = isButtonEnabled
        }
      })
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.isLoading }
      .bind(to: self.rx.isLoading)
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Functions
  
  // MARK: - UI Setups
  
  public override func setupLayouts() {
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
  
  public override func setupConstraints() {
    self.scrollView.snp.makeConstraints { make in
      make.directionalVerticalEdges.equalTo(self.view.safeAreaLayoutGuide)
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
