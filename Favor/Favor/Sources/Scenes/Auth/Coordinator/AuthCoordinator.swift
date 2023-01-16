//
//  AuthCoordinator.swift
//  Favor
//
//  Created by 이창준 on 2023/01/09.
//

import OSLog
import UIKit

final class AuthCoordinator: BaseCoordinator {
  
  // MARK: - Properties
  
  // MARK: - Initializer
  
  // MARK: - Functions
  
  override func start() {
    self.showSelectSignInFlow()
  }
  
}

extension AuthCoordinator {
  
  /// 로그인 방법을 선택하는 View입니다.
  func showSelectSignInFlow() {
    let selectSignInVC = SelectSignInViewController()
    selectSignInVC.reactor = SelectSignInReactor(coordinator: self)
    self.navigationController.pushViewController(selectSignInVC, animated: true)
  }
  
  /// 아이디로 로그인을 선택했을 때의 View입니다.
  func showSignInFlow() {
    let signInVC = SignInViewController()
    signInVC.reactor = SignInReactor(coordinator: self)
    signInVC.title = "로그인"
    self.navigationController.pushViewController(signInVC, animated: true)
  }
  
  /// 회원가입 화면을 담당하는 View입니다.
  func showSignUpFlow() {
    let signUpVC = SignUpViewController()
    signUpVC.reactor = SignUpReactor(coordinator: self)
    signUpVC.title = "신규 가입"
    self.navigationController.pushViewController(signUpVC, animated: true)
  }
  
  /// 회원가입 정보 입력 후 프로필 설정을 진행하는 View입니다.
  func showSetProfileFlow() {
    let setProfileVC = SetProfileViewController()
    setProfileVC.reactor = SetProfileReactor(coordinator: self)
    setProfileVC.title = "프로필 생성"
    self.navigationController.pushViewController(setProfileVC, animated: true)
  }
  
  /// 이용 약관 동의 View입니다.
  func showTermFlow() {
    
  }
  
}
