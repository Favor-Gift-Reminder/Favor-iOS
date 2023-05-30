//
//  ShareTarget.swift
//  Favor
//
//  Created by 이창준 on 2023/05/30.
//

import UIKit

public enum ShareTarget {
  case instagram(UIImage? = nil, UIImage? = nil)
  case facebook
  case photos

  public var title: String {
    switch self {
    case .instagram:
      return "인스타그램"
    case .facebook:
      return "페이스북"
    case .photos:
      return "사진에 저장"
    }
  }

  public var rawValue: String {
    switch self {
    case .instagram:
      return "instagram"
    case .facebook:
      return "facebook"
    case .photos:
      return "photos"
    }
  }
}
