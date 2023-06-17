//
//  SearchSection.swift
//  Favor
//
//  Created by 이창준 on 6/13/23.
//

import UIKit

import Composer
import FavorKit

// MARK: - Item

public enum SearchSectionItem: ComposableItem {
  case recent(RecentSearch)
}

// MARK: - Section

public enum SearchSection: ComposableSection {
  case recent
}

// MARK: - Hashable

extension SearchSectionItem: Hashable {
  public static func == (lhs: SearchSectionItem, rhs: SearchSectionItem) -> Bool {
    switch (lhs, rhs) {
    case let (.recent(lhsSearch), .recent(rhsSearch)):
      return lhsSearch.queryString == rhsSearch.queryString
    }
  }

  public func hash(into hasher: inout Hasher) {
    switch self {
    case .recent(let search):
      hasher.combine(search.queryString)
    }
  }
}

// MARK: - Composer

extension SearchSection: Composable {
  public var item: UICollectionViewComposableLayout.Item {
    return .full()
  }

  public var group: UICollectionViewComposableLayout.Group {
    return .singleFullList(
      height: .absolute(48),
      contentInsets: NSDirectionalEdgeInsets(top: .zero, leading: 20, bottom: .zero, trailing: 20)
    )
  }

  public var section: UICollectionViewComposableLayout.Section {
    return .base(boundaryItems: [
      .header(
        height: .absolute(35),
        contentInsets: NSDirectionalEdgeInsets(top: .zero, leading: 20, bottom: 13, trailing: 20)
      )
    ])
  }
}
