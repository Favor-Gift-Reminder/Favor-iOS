//
//  NewGiftFriendSection.swift
//  Favor
//
//  Created by 김응철 on 2023/04/14.
//

import UIKit

import FavorKit

enum NewGiftFriendItem {
  case empty
  case friend(NewGiftFriendCellReactor)
  
  var reactor: NewGiftFriendCellReactor? {
    switch self {
    case .empty:
      return nil
    case .friend(let reactor):
      return reactor
    }
  }
}

enum NewGiftFriendSection: Int, SectionModelType {
  case selectedFriends
  case friends
}

// MARK: - Hashable

extension NewGiftFriendItem: SectionModelItem {
  static func == (lhs: NewGiftFriendItem, rhs: NewGiftFriendItem) -> Bool {
    switch (lhs, rhs) {
    case (.empty, .empty):
      return true
    case let (.friend(lhsReactor), .friend(rhsReactor)):
      return lhsReactor === rhsReactor
    default:
      return false
    }
  }
  
  func hash(into hasher: inout Hasher) {
    switch self {
    case .empty:
      hasher.combine(0)
    case .friend(let reactor):
      hasher.combine(1)
      hasher.combine(ObjectIdentifier(reactor))
    }
  }
}
