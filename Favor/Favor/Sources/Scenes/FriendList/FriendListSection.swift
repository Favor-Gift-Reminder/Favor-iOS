//
//  FriendListSection.swift
//  Favor
//
//  Created by 이창준 on 2023/04/25.
//

import UIKit

import Composer
import FavorKit

// MARK: - Item

public enum FriendSectionItem: ComposableItem {
  case empty
  case friend(Friend)
}

// MARK: - Section

public enum FriendSection: ComposableSection {
  case empty
  case friend
  case editFriend
}

// MARK: - Hashable

extension FriendSectionItem {
  public static func == (lhs: FriendSectionItem, rhs: FriendSectionItem) -> Bool {
    switch (lhs, rhs) {
    case (.empty, .empty):
      return true
    case let (.friend(lhsValue), .friend(rhsValue)):
      return lhsValue.friendNo == rhsValue.friendNo
    default:
      return false
    }
  }

  public func hash(into hasher: inout Hasher) {
    switch self {
    case .empty:
      hasher.combine("Empty")
    case .friend(let friend):
      hasher.combine(friend.friendNo)
    }
  }
}

// MARK: - Composer

extension FriendSection: Composable {
  public var item: UICollectionViewComposableLayout.Item {
    switch self {
    case .empty:
      return .full()
    case .friend, .editFriend:
      return .listRow(
        height: .absolute(48),
        contentInsets: .zero
      )
    }
  }

  public var group: UICollectionViewComposableLayout.Group {
    switch self {
    case .empty:
      return .full()
    case .friend, .editFriend:
      return .list(spacing: .fixed(8))
    }
  }

  public var section: UICollectionViewComposableLayout.Section {
    switch self {
    case .empty:
      return .base()
    case .friend:
      return .base(
        spacing: 8,
        contentInsets: NSDirectionalEdgeInsets(
          top: 15, leading: .zero, bottom: 15, trailing: .zero
        ),
        boundaryItems: [
          .header(
            height: .absolute(21.0)
          )
        ]
      )
    case .editFriend:
      return .base(
        spacing: 8,
        contentInsets: NSDirectionalEdgeInsets(
          top: 15, leading: .zero, bottom: 15, trailing: .zero
        )
      )
    }
  }
}
