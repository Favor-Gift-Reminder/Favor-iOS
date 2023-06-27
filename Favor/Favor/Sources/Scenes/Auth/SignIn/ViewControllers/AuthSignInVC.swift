//
//  AuthSignInVC.swift
//  Favor
//
//  Created by 이창준 on 2023/01/12.
//

import AuthenticationServices
import UIKit

import FavorKit
import ReactorKit
import RxCocoa
import RxGesture
import SnapKit

public final class AuthSignInViewController: BaseViewController, View {

  // MARK: - Constants

  private enum Typo {
    static let emailPlaceholder: String = "이메일"
    static let passwordPlaceholder: String = "비밀번호"
    static let signIn: String = "로그인"
    static let socialSignIn: String = "소셜 로그인"
    static let findPassword: String = "비밀번호를 잊어버렸어요."
  }

  // MARK: - Properties

  private let keychain = KeychainManager()

  // MARK: - UI Components
  
  private let emailTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.placeholder = Typo.emailPlaceholder
    textField.textField.keyboardType = .emailAddress
    textField.textField.returnKeyType = .next
    return textField
  }()
  
  private let passwordTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.placeholder = Typo.passwordPlaceholder
    textField.isSecureField = true
    textField.textField.returnKeyType = .done
    return textField
  }()

  private let signInStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 36
    return stackView
  }()
  
  private let signInButton = FavorLargeButton(with: .main(Typo.signIn))

  private let socialSignInLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 14)
    label.textColor = .favorColor(.subtext)
    label.text = Typo.socialSignIn
    return label
  }()

  private let socialSignInButtonStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 20
    AuthState.allCases.forEach {
      if $0.isSocialAuth {
        stackView.addArrangedSubview(SocialAuthButton($0))
      }
    }
    return stackView
  }()

  private let findPasswordButton = FavorPlainButton(with: .navigate(Typo.findPassword, isRight: false))

  // MARK: - Binding
  
  public func bind(reactor: AuthSignInViewReactor) {
    // Action
    self.rx.viewDidLoad
      .map { Reactor.Action.viewNeedsLoaded }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.rx.viewDidAppear
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, _ in
        owner.emailTextField.becomeFirstResponder()
      })
      .disposed(by: self.disposeBag)

    self.emailTextField.rx.text
      .orEmpty
      .distinctUntilChanged()
      .map { Reactor.Action.emailDidUpdate($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.emailTextField.rx.editingDidEndOnExit
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, _ in
        owner.passwordTextField.textField.becomeFirstResponder()
      })
      .disposed(by: self.disposeBag)

    self.passwordTextField.rx.text
      .orEmpty
      .distinctUntilChanged()
      .map { Reactor.Action.passwordDidUpdate($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.passwordTextField.rx.editingDidEndOnExit
      .do(onNext: {
        self.passwordTextField.resignFirstResponder()
      })
      .delay(.milliseconds(500), scheduler: MainScheduler.instance)
      .map { Reactor.Action.signInButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.signInButton.rx.tap
      .map { Reactor.Action.signInButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.socialSignInButtonStackView.arrangedSubviews.forEach { arrangedSubview in
      guard let button = arrangedSubview as? SocialAuthButton else { return }
      button.rx.tap
        .map { Reactor.Action.socialSignInButtonDidTap(button.authMethod) }
        .bind(to: reactor.action)
        .disposed(by: self.disposeBag)
    }

    self.findPasswordButton.rx.tap
      .map { Reactor.Action.findPasswordButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.view.rx.tapGesture()
      .when(.recognized)
      .asDriver(onErrorRecover: { _ in return .never()})
      .drive(with: self, onNext: {  owner, _ in
        owner.view.endEditing(true)
      })
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.map { $0.isSignInButtonEnabled }
      .asDriver(onErrorRecover: { _ in return .never()})
      .drive(with: self, onNext: { owner, isEnabled in
        owner.signInButton.isEnabled = isEnabled
      })
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.requestedSocialAuth }
      .asDriver(onErrorRecover: { _ in return .never()})
      .drive(with: self, onNext: { owner, socialAuth in
        switch socialAuth {
        case .apple:
          owner.handleSignInWithApple()
        default: break
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
      self.emailTextField,
      self.passwordTextField
    ].forEach {
      self.signInStackView.addArrangedSubview($0)
    }

    [
      self.signInStackView,
      self.signInButton,
      self.socialSignInLabel,
      self.socialSignInButtonStackView,
      self.findPasswordButton
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  public override func setupConstraints() {
    self.signInStackView.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(56)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
    }

    self.signInButton.snp.makeConstraints { make in
      make.top.equalTo(self.signInStackView.snp.bottom).offset(56)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
    }

    self.socialSignInLabel.snp.makeConstraints { make in
      make.top.equalTo(self.signInButton.snp.bottom).offset(36)
      make.centerX.equalToSuperview()
    }

    self.socialSignInButtonStackView.snp.makeConstraints { make in
      make.top.equalTo(self.socialSignInLabel.snp.bottom).offset(16)
      make.centerX.equalToSuperview()
    }

    self.findPasswordButton.snp.makeConstraints { make in
      make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top).offset(-32)
      make.centerX.equalToSuperview()
    }
  }
  
}

// MARK: - Sign in With

extension AuthSignInViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
  func handleSignInWithApple() {
    let provider = ASAuthorizationAppleIDProvider()
    let request = provider.createRequest()
    request.requestedScopes = [.fullName, .email]

    let authorizationController = ASAuthorizationController(authorizationRequests: [request])
    authorizationController.delegate = self
    authorizationController.presentationContextProvider = self
    authorizationController.performRequests()
  }

  public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return self.view.window!
  }

  public func authorizationController(
    controller: ASAuthorizationController,
    didCompleteWithAuthorization authorization: ASAuthorization
  ) {
    guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }

    // Create an account in your system.
    let userIdentifier = appleIDCredential.user
    let fullName = appleIDCredential.fullName
    let email = appleIDCredential.email

    // Handle Sign Up Task
    guard
      let encodedUserID = userIdentifier.data(using: .utf8),
      let reactor = self.reactor,
      let email = email,
      let familyName = fullName?.familyName,
      let givenName = fullName?.givenName
    else { return }
    do {
      try self.keychain.set(value: encodedUserID, account: KeychainManager.Accounts.userID.rawValue)
      FTUXStorage.authState = .apple
      reactor.action.onNext(.signedInWithApple(email, familyName + givenName))
    } catch {
      print(error)
    }
  }

  public func authorizationController(
    controller: ASAuthorizationController,
    didCompleteWithError error: Error
  ) {
    print(error)
  }
}
