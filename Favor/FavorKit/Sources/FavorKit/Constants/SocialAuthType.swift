//
//  SocialAuthType.swift
//  Favor
//
//  Created by 이창준 on 6/21/23.
//

import UIKit

public enum SocialAuthType: CaseIterable {
  case kakao
  case naver
  case apple

  public var icon: UIImage? {
    switch self {
    case .kakao: return .favorIcon(.kakao)
    case .naver: return .favorIcon(.naver)
    case .apple: return .favorIcon(.apple)
    }
  }

  public enum Size { case large, small }
  public func iconSize(_ size: Size) -> CGFloat {
    switch self {
    case .kakao, .apple:
      return size == .large ? 24.0 : 16.0
    case .naver:
      return size == .large ? 20.0 : 14.0
    }
  }

  public var backgroundColor: UIColor {
    switch self {
    case .kakao: return .favorColor(.kakao)
    case .naver: return .favorColor(.naver)
    case .apple: return .favorColor(.apple)
    }
  }

  public var foregroundColor: UIColor {
    switch self {
    case .kakao: return .favorColor(.black)
    case .naver, .apple: return .favorColor(.white)
    }
  }
}
