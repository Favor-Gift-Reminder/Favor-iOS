//
//  AuthState.swift
//  Favor
//
//  Created by 이창준 on 6/21/23.
//

import UIKit

public enum AuthState: String, CaseIterable, Codable {
  case email = "이메일"
  case kakao = "카카오"
  case naver = "네이버"
  case apple = "애플"
  case undefined = "로그인"

  public var isSocialAuth: Bool {
    switch self {
    case .kakao, .naver, .apple: return true
    case .email, .undefined: return false
    }
  }

  public var icon: UIImage? {
    switch self {
    case .kakao: return .favorIcon(.kakao)
    case .naver: return .favorIcon(.naver)
    case .apple: return .favorIcon(.apple)
    case .email, .undefined: return nil
    }
  }

  public enum Size { case large, small }
  public func iconSize(_ size: Size) -> CGFloat {
    switch self {
    case .kakao, .apple:
      return size == .large ? 24.0 : 16.0
    case .naver:
      return size == .large ? 20.0 : 14.0
    case .email, .undefined: return 0.0
    }
  }

  public var backgroundColor: UIColor {
    switch self {
    case .kakao: return .favorColor(.kakao)
    case .naver: return .favorColor(.naver)
    case .apple: return .favorColor(.apple)
    case .email, .undefined: return .black
    }
  }

  public var foregroundColor: UIColor {
    switch self {
    case .kakao: return .favorColor(.black)
    case .naver, .apple: return .favorColor(.white)
    case .email, .undefined: return .black
    }
  }
}
