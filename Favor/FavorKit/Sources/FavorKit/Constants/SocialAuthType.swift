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

  public var backgroundColor: UIColor {
    switch self {
    case .kakao: return .favorColor(.kakao)
    case .naver: return .favorColor(.naver)
    case .apple: return .favorColor(.apple)
    }
  }
}
