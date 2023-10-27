//
//  NewGiftFriendSection.swift
//  Favor
//
//  Created by 김응철 on 2023/04/14.
//

import UIKit

import Composer
import FavorKit

// MARK: - Item

enum NewGiftFriendItem: ComposableItem {
  case empty
  case friend(friend: Friend, buttonType: FriendSelectorCell.RightButtonType)
}

// MARK: - Section

enum NewGiftFriendSection: ComposableSection {
  case selectedFriends
  case friends
}
