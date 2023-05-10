//
//  NewGiftFriendSection.swift
//  Favor
//
//  Created by 김응철 on 2023/04/14.
//

import UIKit

import FavorKit

enum NewGiftFriendSection: Hashable {
  case selectedFriends
  case friends
  
  /// 각 헤더의 높이 값 입니다.
  var headerHeight: NSCollectionLayoutDimension {
    switch self {
    case .selectedFriends:
      return .absolute(54)
    case .friends:
      return .absolute(100)
    }
  }
}

enum NewGiftFriendItem: Hashable {
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
