//
//  ProfileSection.swift
//  Favor
//
//  Created by 이창준 on 2023/02/12.
//

import UIKit

import FavorKit
import RxDataSources

enum ProfileElementKind {
  static let collectionHeader = "Profile.CollectionHeader"
  static let collectionFooter = "Profile.CollectionFooter"
  static let sectionBackground = "Profile.SectionBackground"
}

enum ProfileSectionItem {
  case profileSetupHelper(FavorSetupProfileCellReactor)
  case preferences(FavorPrefersCellReactor)
  case anniversaries(FavorAnniversaryCellReactor)
  case memo
  case friends(ProfileFriendCellReactor)
}

enum ProfileSection {
  case profileSetupHelper([ProfileSectionItem])
  case preferences([ProfileSectionItem])
  case anniversaries([ProfileSectionItem])
  case memo([ProfileSectionItem])
  case friends([ProfileSectionItem])
}

extension ProfileSection: SectionModelType {
  public var items: [ProfileSectionItem] {
    switch self {
    case .profileSetupHelper(let items):
      return items
    case .preferences(let items):
      return items
    case .anniversaries(let items):
      return items
    case .memo(let items):
      return items
    case .friends(let items):
      return items
    }
  }
  
  public init(original: ProfileSection, items: [ProfileSectionItem]) {
    switch original {
    case .profileSetupHelper:
      self = .profileSetupHelper(items)
    case .preferences:
      self = .preferences(items)
    case .anniversaries:
      self = .anniversaries(items)
    case .memo:
      self = .memo(items)
    case .friends:
      self = .friends(items)
    }
  }

  var headerTitle: String? {
    switch self {
    case .profileSetupHelper: return "새 프로필"
    case .preferences: return "취향"
    case .anniversaries: return "기념일"
    case .memo: return "메모"
    case .friends: return "친구"
    }
  }
}

// MARK: - Adapter

extension ProfileSection: Adaptive {
  public var item: FavorCompositionalLayout.Item {
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
    case .memo:
      return .listRow(
        height: .estimated(130)
      )
    case .friends:
      return .grid(
        width: .absolute(60),
        height: .fractionalHeight(1.0)
      )
    }
  }

  public var group: FavorCompositionalLayout.Group {
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
    case .memo:
      return .list(
        height: .estimated(130),
        numberOfItems: 1
      )
    case .friends:
      return .flow(
        height: .estimated(85),
        numberOfItems: 10,
        spacing: .fixed(26)
      )
    }
  }

  public var section: FavorCompositionalLayout.Section {
    let header = FavorCompositionalLayout.BoundaryItem.header(height: .estimated(32))
    let background = FavorCompositionalLayout.DecorationItem.background(
      kind: ProfileElementKind.sectionBackground
    )

    let defaultInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: .zero, trailing: 20)

    switch self {
    case .profileSetupHelper:
      return .base(
        contentInsets: defaultInsets,
        orthogonalScrolling: .paging,
        boundaryItems: [header],
        decorationItems: [background]
      )
    case .preferences:
      return .base(
        contentInsets: defaultInsets,
        orthogonalScrolling: .continuous,
        boundaryItems: [header],
        decorationItems: [background]
      )
    case .anniversaries:
      return .base(
        spacing: 10,
        contentInsets: defaultInsets,
        boundaryItems: [header],
        decorationItems: [background]
      )
    case .memo:
      return .base(
        contentInsets: defaultInsets,
        boundaryItems: [header]
      )
    case .friends:
      return .base(
        contentInsets: NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 66, trailing: 20),
        orthogonalScrolling: .continuous,
        boundaryItems: [header]
      )
    }
  }
}
