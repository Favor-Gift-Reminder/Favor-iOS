//
//  FavorEmotion.swift
//  Favor
//
//  Created by 이창준 on 6/15/23.
//

import Foundation

// TODO: 임시 감정
public enum FavorEmotion: String, Codable, CaseIterable {
  case touching = "감동이에요"
  case excited = "기뻐요"
  case good = "좋아요"
  case xoxo = "그냥그래요"
  case boring = "별로에요"
  
  public var index: Int {
    switch self {
    case .touching: 0
    case .excited: 1
    case .good: 2
    case .xoxo: 3
    case .boring: 4
    }
  }
  
  public var emoji: String {
    switch self {
    case .touching:
      return "🥹"
    case .excited:
      return "🥰"
    case .good:
      return "🙂"
    case .xoxo:
      return "😐"
    case .boring:
      return "😰"
    }
  }
}
