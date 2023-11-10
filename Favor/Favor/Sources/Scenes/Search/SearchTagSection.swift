//
//  SearchCategorySection.swift
//  Favor
//
//  Created by 이창준 on 6/15/23.
//

import UIKit

import Composer

// MARK: - Item

public enum SearchTagSectionItem: ComposableItem {
  case empty(UIImage?, String)
  case gift(Gift)
}

// MARK: - Section

public enum SearchTagSection: ComposableSection {
  case empty
  case gift
}

// MARK: - Hashable

extension SearchTagSectionItem: Hashable {
  public static func == (lhs: SearchTagSectionItem, rhs: SearchTagSectionItem) -> Bool {
    switch (lhs, rhs) {
    case (.empty, .empty):
      return false
    case let (.gift(lhsGift), .gift(rhsGift)):
      return lhsGift == rhsGift
    default:
      return false
    }
  }

  public func hash(into hasher: inout Hasher) {
    switch self {
    case .empty:
      hasher.combine("empty")
    case .gift(let gift):
      hasher.combine(gift)
    }
  }
}

// MARK: - Composer

extension SearchTagSection: Composable {
  public var item: UICollectionViewComposableLayout.Item {
    switch self {
    case .empty:
      return .full()
    case .gift:
      return .grid(
        width: .fractionalWidth(0.5),
        height: .fractionalWidth(0.5)
      )
    }
  }

  public var group: UICollectionViewComposableLayout.Group {
    switch self {
    case .empty:
      return .full()
    case .gift:
      return .grid(height: .fractionalWidth(0.5), numberOfItems: 2, spacing: .fixed(6))
    }
  }

  public var section: UICollectionViewComposableLayout.Section {
    switch self {
    case .empty:
      return .base()
    case .gift:
      return .base(
        contentInsets: NSDirectionalEdgeInsets(top: .zero, leading: 20, bottom: 32, trailing: 20)
      )
    }
  }
}
