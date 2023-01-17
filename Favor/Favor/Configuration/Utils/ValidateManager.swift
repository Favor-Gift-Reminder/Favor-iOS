//
//  ValidateManager.swift
//  Favor
//
//  Created by 이창준 on 2023/01/16.
//

import Foundation

enum ValidateManager {
  
  enum EmailValidate {
    case empty
    case invalid
    case valid
    
    static let regex: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    
    var description: String? {
      switch self {
      case .empty:
        return "이메일을 입력해주세요."
      case .invalid:
        return "올바르지 않은 이메일 형식입니다."
      case .valid:
        return nil
      }
    }
  }
  
  static func validate(email: String) -> EmailValidate {
    guard !email.isEmpty else {
      return .empty
    }
    guard email.range(of: EmailValidate.regex, options: .regularExpression) != nil else {
      return .invalid
    }
    return .valid
  }
  
  enum PasswordValidate {
    case empty
    case invalid
    case valid
    
    static let regex: String = "^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,50}" // 8~50자리 영어/숫자/특수문자
    
    var description: String {
      switch self {
      case .empty:
        return "비밀번호를 입력해주세요."
      case .invalid:
        return "올바르지 않은 비밀번호 형식입니다."
      case .valid:
        return ""
      }
    }
  }
  
  static func validate(password: String) -> PasswordValidate {
    guard !password.isEmpty else {
      return .empty
    }
    guard password.range(of: PasswordValidate.regex, options: .regularExpression) != nil else {
      return .invalid
    }
    return .valid
  }
  
  enum CheckPasswordValidate {
    case empty
    case identical
    case different
    
    var description: String {
      switch self {
      case .empty:
        return "비밀번호를 한번 더 입력해주세요."
      case .different:
        return "비밀번호가 일치하지 않습니다."
      case .identical:
        return ""
      }
    }
  }
  
  static func validate(checkPassword: String, to password: String) -> CheckPasswordValidate {
    guard !checkPassword.isEmpty else { return .empty }
    guard checkPassword == password else { return .different }
    return .identical
  }
  
}
