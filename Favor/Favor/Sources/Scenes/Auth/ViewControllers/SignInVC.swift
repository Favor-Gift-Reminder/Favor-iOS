//
//  SignInVC.swift
//  Favor
//
//  Created by 이창준 on 2023/01/11.
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
  
  private lazy var temporaryLogo = UILabel().then {
    $0.font = .systemFont(ofSize: 48, weight: .bold)
    $0.text = "Favor"
  }
  
  private lazy var kakaoLoginButton = UIFactory.favorButton(
    with: .large,
    title: "카카오로 로그인"
  )
  
  private lazy var idLoginButton = UIFactory.favorButton(
    with: .large,
    title: "내 아이디로 로그인"
  )
  
  private lazy var signUpButton = UIFactory.favorButton(
    with: .plain,
    title: "신규 회원가입"
  )
  
  private lazy var vStack = UIStackView().then {
    $0.spacing = 8.0
    $0.addArrangedSubview(self.kakaoLoginButton)
    $0.addArrangedSubview(self.idLoginButton)
    $0.addArrangedSubview(self.signUpButton)
    $0.axis = .vertical
  }
  
  // MARK: - Life Cycle
  
  // MARK: - Binding
  
  func bind(reactor: SignInReactor) {
    //
  }
  
  // MARK: - Functions
  
  // MARK: - UI Setups
  
  override func setupLayouts() {
    [self.temporaryLogo, self.vStack].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    
    self.temporaryLogo.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview().offset(-48)
    }
    
    self.vStack.snp.makeConstraints { make in
      make.bottom.equalTo(self.view.safeAreaLayoutGuide)
      make.leading.trailing.equalTo(self.view.layoutMarginsGuide)
    }
  }
  
}
