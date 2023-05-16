//
//  AnniversaryListSection.swift
//  Favor
//
//  Created by 이창준 on 2023/05/16.
//

import UIKit

import FavorKit

// MARK: - Item

public enum AnniversaryListSectionItem: SectionModelItem {
  case empty
  case anniversary(AnniversaryListCellReactor)
}

// MARK: - Section

public enum AnniversaryListSection: SectionModelType {
  case empty
  case pinned
  case all
}

// MARK: - Hashable & Equatable

extension AnniversaryListSectionItem: Hashable, Equatable {
  public static func == (lhs: AnniversaryListSectionItem, rhs: AnniversaryListSectionItem) -> Bool {
    switch (lhs, rhs) {
    case let (.anniversary(lhsValue), .anniversary(rhsValue)):
      return true
    default:
      return false
    }
  }

  public func hash(into hasher: inout Hasher) {
    switch self {
    case .empty:
      hasher.combine("Empty")
    case .anniversary(let reactor):
      hasher.combine("Anniversary")
    }
  }
}

// MARK: - Adapter

extension AnniversaryListSection: Adaptive {
  public var item: FavorCompositionalLayout.Item {
    switch self {
    case .empty:
      return .full()
    case .pinned, .all:
      return .listRow(height: .absolute(95))
    }
  }

  public var group: FavorCompositionalLayout.Group {
    switch self {
    case .empty:
      return .full()
    case .pinned, .all:
      return .list(
        height: .estimated(1),
        numberOfItems: 1,
        spacing: .fixed(10),
        contentInsets: nil,
        innerGroup: nil
      )
    }
  }

  public var section: FavorCompositionalLayout.Section {
    return .base()
  }
}
