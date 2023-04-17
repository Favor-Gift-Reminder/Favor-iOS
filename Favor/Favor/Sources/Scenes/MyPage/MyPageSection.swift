//
//  MyPageSection.swift
//  Favor
//
//  Created by 이창준 on 2023/02/12.
//

import UIKit

import FavorKit
import RxDataSources

enum MyPageSectionItem {
  case profileSetupHelper(FavorSetupProfileCellReactor)
  case preferences(FavorPrefersCellReactor)
  case anniversaries(FavorAnniversaryCellReactor)
}

enum MyPageSection {
  case profileSetupHelper([MyPageSectionItem])
  case preferences([MyPageSectionItem])
  case anniversaries([MyPageSectionItem])
}

extension MyPageSection: SectionModelType {
  var items: [MyPageSectionItem] {
    switch self {
    case .profileSetupHelper(let items):
      return items
    case .preferences(let items):
      return items
    case .anniversaries(let items):
      return items
    }
  }
  
  init(original: MyPageSection, items: [MyPageSectionItem]) {
    switch original {
    case .profileSetupHelper:
      self = .profileSetupHelper(items)
    case .preferences:
      self = .preferences(items)
    case .anniversaries:
      self = .anniversaries(items)
    }
  }

  var headerTitle: String? {
    switch self {
    case .profileSetupHelper: return "새 프로필"
    case .preferences: return "취향"
    case .anniversaries: return "기념일"
    }
  }
}

// MARK: - Adapter

extension MyPageSection: Adaptive {
  var item: FavorCompositionalLayout.Item {
    switch self {
    case .profileSetupHelper:
      return .grid(
        width: .absolute(250),
        height: .absolute(250)
      )
    case .preferences:
      return .grid(
        width: .estimated(50),
        height: .absolute(32)
      )
    case .anniversaries:
      return .listRow(
        height: .absolute(95)
      )
    }
  }

  var group: FavorCompositionalLayout.Group {
    switch self {
    case .profileSetupHelper:
      return .contents(
        width: .estimated(250),
        height: .estimated(250),
        direction: .horizontal,
        numberOfItems: 2,
        spacing: .fixed(8)
      )
    case .preferences:
      return .flow(
        height: .estimated(32),
        numberOfItems: 3,
        spacing: .fixed(10)
      )
    case .anniversaries:
      return .list(
        height: .estimated(95),
        numberOfItems: 3,
        spacing: .fixed(10)
      )
    }
  }

  var section: FavorCompositionalLayout.Section {
    let header = FavorCompositionalLayout.BoundaryItem.header(height: .estimated(32))

    switch self {
    case .profileSetupHelper:
      return .base(
        spacing: 8,
        contentInsets: NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: .zero, trailing: 20),
        orthogonalScrolling: .paging,
        boundaryItems: [header]
      )
    case .preferences:
      return .base(
        spacing: 10,
        contentInsets: NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: .zero, trailing: 20),
        orthogonalScrolling: .continuous,
        boundaryItems: [header]
      )
    case .anniversaries:
      return .base(
        spacing: 10,
        contentInsets: NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: .zero, trailing: 20),
        boundaryItems: [header]
      )
    }
  }
}
