//
//  AuthCoordinator.swift
//  Favor
//
//  Created by 이창준 on 2023/01/09.
//

import UIKit

final class AuthCoordinator: BaseCoordinator {
  
  // MARK: - Properties
  
  // MARK: - Initializer
  
  // MARK: - Functions
  
  override func start() {
    self.showSignInFlow()
  }
  
}

extension AuthCoordinator {
  
  /// 로그인 화면을 담당하는 View입니다.
  func showSignInFlow() {
    
  }
  
  /// 회원가입 화면을 담당하는 View입니다.
  func showSignUpFlow() {
    
  }
  
  /// 회원가입 정보 입력 후 프로필 설정을 진행하는 View입니다.
  func showSetProfileFlow() {
    
  }
  
  /// 이용 약관 동의 View입니다.
  func showTermFlow() {
    
  }
}
