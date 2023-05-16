//
//  FriendSection.swift
//  Favor
//
//  Created by 이창준 on 2023/04/25.
//

import UIKit

import FavorKit

public enum FriendSectionItem: SectionModelItem {
  case empty
  case friend(Friend)
}

public enum FriendSection: SectionModelType {
  case empty
  case friend
  case editFriend
}

extension FriendSectionItem: Equatable, Hashable {
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

// MARK: - Adapter

extension FriendSection: Adaptive {
  public var item: FavorCompositionalLayout.Item {
    switch self {
    case .empty:
      return .full()
    case .friend, .editFriend:
      return .listRow(
        height: .fractionalHeight(1.0),
        contentInsets: .zero
      )
    }
  }

  public var group: FavorCompositionalLayout.Group {
    switch self {
    case .empty:
      return .full()
    case .friend, .editFriend:
      return .list(
        height: .absolute(48),
        numberOfItems: 1,
        spacing: .fixed(8),
        contentInsets: .zero
      )
    }
  }

  public var section: FavorCompositionalLayout.Section {
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
