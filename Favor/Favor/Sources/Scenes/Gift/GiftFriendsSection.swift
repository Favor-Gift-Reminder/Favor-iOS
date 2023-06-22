//
//  GiftFriendsSection.swift
//  Favor
//
//  Created by 이창준 on 6/20/23.
//

import UIKit

import Composer
import FavorKit

// MARK: - Item

public struct GiftFriendsSectionItem: ComposableItem {
  public var friend: Friend
}

// MARK: - Section

public enum GiftFriendsSection: ComposableSection {
  case friends
}

// MARK: - Hashable

extension GiftFriendsSectionItem: Hashable {
  public static func == (lhs: GiftFriendsSectionItem, rhs: GiftFriendsSectionItem) -> Bool {
    return lhs.friend == rhs.friend
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.friend.identifier)
  }
}

extension GiftFriendsSection: Hashable {
  public static func == (lhs: GiftFriendsSection, rhs: GiftFriendsSection) -> Bool {
    switch (lhs, rhs) {
    case (.friends, .friends): return true
    }
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine("GiftFriend")
  }
}

// MARK: - Composer

extension GiftFriendsSection: Composable {
  public var item: UICollectionViewComposableLayout.Item {
    return .grid(width: .absolute(60), height: .fractionalHeight(1.0))
  }
  
  public var group: UICollectionViewComposableLayout.Group {
    return .custom(width: .absolute(60), height: .fractionalHeight(1.0), direction: .horizontal, numberOfItems: 1)
  }
  
  public var section: UICollectionViewComposableLayout.Section {
    return .base(spacing: 26)
  }
}
