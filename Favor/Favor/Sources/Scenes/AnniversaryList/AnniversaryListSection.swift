//
//  AnniversaryListSection.swift
//  Favor
//
//  Created by 이창준 on 2023/05/16.
//

import UIKit

import Composer
import FavorKit

// MARK: - Item

public enum AnniversaryListSectionItem: ComposableItem {
  case empty
  case anniversary(
    _ type: AnniversaryListCell.CellType,
    anniversary: Anniversary,
    for: AnniversaryListSection
  )

  var value: Anniversary? {
    switch self {
    case .empty:
      return nil
    case let .anniversary(_, anniversary, _):
      return anniversary
    }
  }
}

// MARK: - Section

public enum AnniversaryListSection: ComposableSection {
  case empty
  case all
  case edit
}

// MARK: - Properties

extension AnniversaryListSection {
  public var header: String {
    switch self {
    case .all:
      return "전체"
    default:
      return ""
    }
  }
}

// MARK: - Hashable & Equatable

extension AnniversaryListSectionItem {
  public static func == (lhs: AnniversaryListSectionItem, rhs: AnniversaryListSectionItem) -> Bool {
    switch (lhs, rhs) {
    case let (.anniversary(_, lhsData, lhsIsPinned), .anniversary(_, rhsData, rhsIsPinned)):
      return (lhsData == rhsData) && (lhsData.isPinned == rhsData.isPinned) && (lhsIsPinned == rhsIsPinned)
    default:
      return false
    }
  }
  
  public func hash(into hasher: inout Hasher) {
    switch self {
    case .empty:
      hasher.combine("Empty")
    case let .anniversary(_, anniversary, _):
      hasher.combine(anniversary.identifier)
      hasher.combine(anniversary.isPinned)
    }
  }
}

// MARK: - Adapter

extension AnniversaryListSection: Composable {
  public var item: UICollectionViewComposableLayout.Item {
    switch self {
    case .empty:
      return .full()
    case .all, .edit:
      return .listRow(height: .absolute(95))
    }
  }

  public var group: UICollectionViewComposableLayout.Group {
    switch self {
    case .empty:
      return .full()
    case .all, .edit:
      return .list()
    }
  }

  public var section: UICollectionViewComposableLayout.Section {
    let header = UICollectionViewComposableLayout.BoundaryItem.header(
      height: .absolute(37),
      contentInsets: NSDirectionalEdgeInsets(top: .zero, leading: .zero, bottom: 15, trailing: .zero)
    )

    switch self {
    case .empty:
      return .base()
    case .all:
      return .base(
        spacing: 10,
        boundaryItems: [header]
      )
    case .edit:
      return .base(spacing: 10)
    }
  }
}
