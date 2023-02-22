//
//  SelectSignInVC.swift
//  Favor
//
//  Created by 이창준 on 2023/01/11.
//

import UIKit

import ReactorKit
import RxCocoa
import SnapKit
import Then

final class SelectSignInViewController: BaseViewController, View {
  
  // MARK: - Constants
  
  // MARK: - Properties
  
  // MARK: - UI Components
  
  private lazy var temporaryLogo: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 48, weight: .bold)
    label.text = "Favor"
    return label
  }()
  
  private lazy var emailLoginButton: LargeFavorButton = {
    let button = LargeFavorButton(with: .main("이메일로 로그인"))
    return button
  }()
  
  private lazy var signUpButton: PlainFavorButton = {
    let button = PlainFavorButton(with: .log_in("신규 회원가입"))
    return button
  }()
  
  private lazy var vStack: UIStackView = {
    let stackView = UIStackView()
    stackView.spacing = 8.0
    stackView.addArrangedSubview(self.emailLoginButton)
    stackView.addArrangedSubview(self.signUpButton)
    stackView.axis = .vertical
    return stackView
  }()

  // MARK: - Life Cycle
  
  // MARK: - Binding
  
  func bind(reactor: SelectSignInReactor) {
    // Action
    
    self.emailLoginButton.rx.tap
      .map { Reactor.Action.emailLoginButtonTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.signUpButton.rx.tap
      .map { Reactor.Action.signUpButtonTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
  }
  
  // MARK: - Functions
  
  // MARK: - UI Setups
  
  override func setupLayouts() {
    [
      self.temporaryLogo,
      self.vStack,
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.temporaryLogo.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview().inset(48)
    }
    
    self.vStack.snp.makeConstraints { make in
      make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(46)
      make.leading.trailing.equalTo(self.view.layoutMarginsGuide)
    }
  }
}
