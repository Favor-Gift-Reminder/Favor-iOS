//
//  AuthSignInVC.swift
//  Favor
//
//  Created by 이창준 on 2023/01/12.
//

import AuthenticationServices
import CryptoKit
import OSLog
import UIKit

import FavorKit
import KakaoSDKUser
import ReactorKit
import RxCocoa
import RxGesture
import RxKakaoSDKUser
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
  private var currentNonce: String?

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
    label.isHidden = true
    return label
  }()

  private let socialSignInButtonStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 20
    stackView.isHidden = true
    AuthState.allCases.forEach {
      if $0.isSocialAuth {
        stackView.addArrangedSubview(SocialAuthButton($0))
      }
    }
    return stackView
  }()
  
  private let findPasswordButton: FavorPlainButton = {
    let button = FavorPlainButton(with: .navigate(Typo.findPassword, isRight: false))
    button.isHidden = true
    return button
  }()

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
        .asDriver(onErrorRecover: { _ in return .empty() })
        .drive(with: self, onNext: { owner, _ in
          owner.handleSocialAuth(button.authMethod)
        })
        .disposed(by: self.disposeBag)
    }

    self.findPasswordButton.rx.tap
      .map { Reactor.Action.findPasswordButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.view.rx.tapGesture()
      .when(.recognized)
      .asDriver(onErrorRecover: { _ in return .never() })
      .drive(with: self, onNext: {  owner, _ in
        owner.view.endEditing(true)
      })
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.map { $0.isSignInButtonEnabled }
      .asDriver(onErrorRecover: { _ in return .never() })
      .drive(with: self, onNext: { owner, isEnabled in
        owner.signInButton.isEnabled = isEnabled
      })
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

// MARK: - Social SignIn

extension AuthSignInViewController {
  private func handleSocialAuth(_ authMethod: AuthState) {
    switch authMethod {
    case .apple:
      self.handleSignInWithApple()
    case .kakao:
      self.handleSignInWithKakao()
    default:
      break
    }
  }
}

// MARK: - Apple

extension AuthSignInViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
  private func handleSignInWithApple() {
    let nonce = self.randomNonceString()
    self.currentNonce = nonce
    let provider = ASAuthorizationAppleIDProvider()
    let request = ASAuthorizationAppleIDProvider().createRequest()

    // Keychain에 UserID가 저장되어 있을 때.
    if let userID = try? self.keychain.get(account: KeychainManager.Accounts.userAppleID.rawValue) {
      let decodedUserID = String(decoding: userID, as: UTF8.self)
      provider.getCredentialState(forUserID: decodedUserID) { state, error in
        switch state {
        case .authorized:
          os_log(.debug, "Authorized")
          let authorizationController = ASAuthorizationController(authorizationRequests: [request])
          authorizationController.delegate = self
          authorizationController.presentationContextProvider = self
          authorizationController.performRequests()
        case .revoked:
          os_log(.debug, "Need re-auth")
        case .notFound:
          os_log(.debug, "Need Sign in")
        case .transferred:
          os_log(.debug, "Transferred")
        @unknown default:
          fatalError()
        }
      }
    } else { // Keychain에 UserID가 없을 때
      os_log(.debug, "No userID found on keychain.")
      request.requestedScopes = [.fullName, .email]
      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = self
      authorizationController.performRequests()
    }
  }

  public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return self.view.window!
  }

  public func authorizationController(
    controller: ASAuthorizationController,
    didCompleteWithAuthorization authorization: ASAuthorization
  ) {
    guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
    guard
      let nonce = self.currentNonce,
      let appleIDToken = credential.identityToken,
      let idTokenString = String(data: appleIDToken, encoding: .utf8)
    else { return }

//    do {
//      try self.keychain.set(value: encodedUserID, account: KeychainManager.Accounts.userID.rawValue)
//      FTUXStorage.authState = .apple
//      reactor.action.onNext(.signedInWithApple(email, familyName + givenName))
//    } catch {
//      os_log(.error, "\(error)")
//    }
  }

  public func authorizationController(
    controller: ASAuthorizationController,
    didCompleteWithError error: Error
  ) {
    os_log(.error, "\(error)")
  }
}

// MARK: - Kakao

extension AuthSignInViewController {
  private func handleSignInWithKakao() {
    if UserApi.isKakaoTalkLoginAvailable() {
      UserApi.shared.rx.loginWithKakaoTalk()
        .subscribe(with: self, onNext: { owner, oauthToken in
          os_log(.debug, "loginWithKakaoTalk() success.")
        }, onError: { owner, error in
          os_log(.error, "\(error)")
        })
        .disposed(by: self.disposeBag)
    } else {
      os_log(.debug, "Kakao login not available.")
    }
  }
}

// MARK: - Privates

private extension AuthSignInViewController {
  func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length

    while remainingLength > 0 {
      let randoms: [UInt8] = (0 ..< 16).map { _ in
        var random: UInt8 = 0
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
        if errorCode != errSecSuccess {
          fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        return random
      }

      randoms.forEach { random in
        if remainingLength == 0 { return }

        if random < charset.count {
          result.append(charset[Int(random)])
          remainingLength -= 1
        }
      }
    }
    return result
  }

  func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
      return String(format: "%02x", $0)
    }.joined()

    return hashString
  }
}
