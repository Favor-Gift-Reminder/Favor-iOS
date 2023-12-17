//
//  AuthTempStorage.swift
//  Favor
//
//  Created by 김응철 on 2023/12/17.
//

import UIKit

/// 회원가입 페이지와 프로필 생성 페이지 간의
/// 데이터(아이디, 비밀번호)를 유지하는 Storage
final class AuthTempStorage {
  
  // MARK: - Properties
  
  static let shared = AuthTempStorage()
  var email: String = ""
  var password: String = ""
  var token: String = ""
  var user: User = .init()
  var profileImage: UIImage?
  
  private init() {}
 
  // MARK: - Functions
  
  func saveEmail(_ email: String) {
    self.email = email
  }
  
  func savePassword(_ password: String) {
    self.password = password
  }
  
  func saveUser(_ user: User) {
    self.user = user
  }
  
  func saveProfileImage(_ image: UIImage?) {
    self.profileImage = image
  }
  
  func saveToken(_ token: String) {
    self.token = token
  }
}
