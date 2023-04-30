//
//  FriendSection.swift
//  Favor
//
//  Created by 이창준 on 2023/04/25.
//

import UIKit

import FavorKit
import RxDataSources

enum FriendSectionItem {
  case friend(FriendCellReactor)
}

enum FriendSection {
  case friend([FriendSectionItem])
}

extension FriendSection: SectionModelType {
  public var items: [FriendSectionItem] {
    switch self {
    case .friend(let items):
      return items
    }
  }

  public init(original: FriendSection, items: [FriendSectionItem]) {
    switch original {
    case .friend:
      self = .friend(items)
    }
  }
}

extension FriendSection: Adaptive {
  var item: FavorCompositionalLayout.Item {
    switch self {
    case .friend:
      return .listRow(
        height: .fractionalHeight(1.0),
        contentInsets: .zero
      )
    }
  }

  var group: FavorCompositionalLayout.Group {
    switch self {
    case .friend:
      return .list(
        height: .absolute(48),
        numberOfItems: 1,
        spacing: .fixed(8),
        contentInsets: .zero
      )
    }
  }

  var section: FavorCompositionalLayout.Section {
    switch self {
    case .friend:
      return .base(
        contentInsets: NSDirectionalEdgeInsets(
          top: 16, leading: 20, bottom: .zero, trailing: 20
        ),
        boundaryItems: [
          .header(height: .estimated(21))
        ]
      )
    }
  }
}
