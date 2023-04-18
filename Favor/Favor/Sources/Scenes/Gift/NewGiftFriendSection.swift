//
//  NewGiftFriendSection.swift
//  Favor
//
//  Created by 김응철 on 2023/04/14.
//

import UIKit

import RxDataSources

enum NewGiftFriendSectionType: Equatable {
  case selectedFriends
  case friendList
}

struct NewGiftFriendSection {
  typealias NewGiftFriendSectionModel = SectionModel<NewGiftFriendSectionType, NewGiftFriendSectionItem>
  
  enum NewGiftFriendSectionItem {
    case empty
    case friend(NewGiftFriendCellReactor)
  }
}

extension NewGiftFriendSectionType {
  var headerHeight: NSCollectionLayoutDimension {
    switch self {
    case .selectedFriends:
      return .absolute(54)
    case .friendList:
      return .absolute(100)
    }
  }
}
