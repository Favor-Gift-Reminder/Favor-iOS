//
//  FriendSection.swift
//  Favor
//
//  Created by 이창준 on 2023/04/25.
//

import UIKit

import FavorKit

public enum FriendSectionItem: SectionModelItem {
  case friend(Friend)
}

public enum FriendSection: SectionModelType {
  case friend
  case editFriend
}

extension FriendSectionItem: Equatable, Hashable {
  public static func == (lhs: FriendSectionItem, rhs: FriendSectionItem) -> Bool {
    switch (lhs, rhs) {
    case let (.friend(lhsValue), .friend(rhsValue)):
      return lhsValue.friendNo == rhsValue.friendNo
    }
  }

  public func hash(into hasher: inout Hasher) {
    switch self {
    case .friend(let friend):
      hasher.combine(friend.friendNo)
    }
  }
}

// MARK: - Adapter

extension FriendSection: Adaptive {
  public var item: FavorCompositionalLayout.Item {
    switch self {
    case .friend, .editFriend:
      return .listRow(
        height: .fractionalHeight(1.0),
        contentInsets: .zero
      )
    }
  }

  public var group: FavorCompositionalLayout.Group {
    switch self {
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
