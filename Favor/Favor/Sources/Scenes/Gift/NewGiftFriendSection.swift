//
//  NewGiftFriendSection.swift
//  Favor
//
//  Created by 김응철 on 2023/04/14.
//

import UIKit

import RxDataSources

enum NewGiftFriendSectionType: Equatable {
  case selected
  case friend
}

struct NewGiftFriendSection {
  typealias NewGiftFriendSectionModel = SectionModel<NewGiftFriendSectionType, NewGiftFriendSectionItem >

  enum NewGiftFriendSectionItem {
    case empty
    case selected
    case check
    case plus
  }
}

extension NewGiftFriendSectionType {
  var headerHeight: NSCollectionLayoutDimension {
    switch self {
    case .selected:
      return .absolute(30)
    case .friend:
      return .absolute(80)
    }
  }
}
