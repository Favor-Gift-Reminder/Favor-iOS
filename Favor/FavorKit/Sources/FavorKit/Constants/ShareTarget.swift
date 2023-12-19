//
//  ShareTarget.swift
//  Favor
//
//  Created by 이창준 on 2023/05/30.
//

import UIKit

public enum ShareTarget {
  case instagram(UIImage? = nil, UIImage? = nil)
  case photos
  
  public var title: String {
    switch self {
    case .instagram:
      return "스토리"
    case .photos:
      return "사진 공유"
    }
  }

  public var rawValue: String {
    switch self {
    case .instagram:
      return "instagram"
    case .photos:
      return "photos"
    }
  }
}
