//
//  SearchResultSection.swift
//  Favor
//
//  Created by 이창준 on 2023/04/14.
//

import UIKit

import Composer
import FavorKit

// MARK: - Item

public enum SearchResultSectionItem: ComposableItem {
  case empty(UIImage?, String)
  case gift(Gift)
  case user(User, isAlreadyFriend: Bool)
}

// MARK: - Section

public enum SearchResultSection: ComposableSection {
  case result(SectionType)

  public enum SectionType {
    case empty, gift, user
  }
}

// MARK: - Hashable

extension SearchResultSectionItem: Hashable {
  public func hash(into hasher: inout Hasher) {
    switch self {
    case .empty:
      hasher.combine("Empty")
    case .gift(let gift):
      hasher.combine(gift)
    case .user(let user, _):
      hasher.combine(user)
    }
  }
}

// MARK: - Composer

extension SearchResultSection: Composable {
  public var item: UICollectionViewComposableLayout.Item {
    guard case let SearchResultSection.result(item) = self else { return .full() }

    switch item {
    case .empty:
      return .full()
    case .gift:
      return .grid(
        width: .fractionalWidth(0.5),
        height: .fractionalWidth(0.5))
    case .user:
      return .full()
    }
  }

  public var group: UICollectionViewComposableLayout.Group {
    guard case let SearchResultSection.result(item) = self else { return .full() }

    switch item {
    case .empty:
      return .full()
    case .gift:
      return .grid(height: .fractionalWidth(0.5), numberOfItems: 2, spacing: .fixed(5))
    case .user:
      return .full()
    }
  }

  public var section: UICollectionViewComposableLayout.Section {
    guard case let SearchResultSection.result(item) = self else { return .base() }

    switch item {
    case .empty:
      return .base()
    case .gift:
      return .base(
        contentInsets: NSDirectionalEdgeInsets(top: 32, leading: 20, bottom: 32, trailing: 20)
      )
    case .user:
      return .base()
    }
  }
}
