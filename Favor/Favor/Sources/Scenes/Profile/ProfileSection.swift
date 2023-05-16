//
//  ProfileSection.swift
//  Favor
//
//  Created by 이창준 on 2023/02/12.
//

import UIKit

import FavorKit

enum ProfileElementKind {
  static let collectionHeader = "Profile.CollectionHeader"
  static let collectionFooter = "Profile.CollectionFooter"
  static let sectionWhiteBackground = "Profile.SectionWhiteBackground"
}

enum ProfileSectionItem: SectionModelItem {
  case profileSetupHelper(ProfileSetupHelperCellReactor)
  case favors(ProfileFavorCellReactor)
  case anniversaries(ProfileAnniversaryCellReactor)
  case memo
  case friends(ProfileFriendCellReactor)
}

enum ProfileSection: SectionModelType {
  case profileSetupHelper
  case favors
  case anniversaries
  case memo
  case friends
}

extension ProfileSectionItem {
  static func == (lhs: ProfileSectionItem, rhs: ProfileSectionItem) -> Bool {
    switch (lhs, rhs) {
    case let (.profileSetupHelper(lhsValue), .profileSetupHelper(rhsValue)):
      return lhsValue === rhsValue
    case let (.favors(lhsValue), .favors(rhsValue)):
      return lhsValue === rhsValue
    case let (.anniversaries(lhsValue), .anniversaries(rhsValue)):
      return lhsValue === rhsValue
    case (.memo, .memo):
      return true
    case let (.friends(lhsValue), .friends(rhsValue)):
      return lhsValue === rhsValue
    default:
      return false
    }
  }

  func hash(into hasher: inout Hasher) {
    switch self {
    case let .profileSetupHelper(reactor):
      hasher.combine(ObjectIdentifier(reactor))
    case let .favors(reactor):
      hasher.combine(ObjectIdentifier(reactor))
    case let .anniversaries(reactor):
      hasher.combine(ObjectIdentifier(reactor))
    case .memo:
      hasher.combine("memo")
    case let .friends(reactor):
      hasher.combine(ObjectIdentifier(reactor))
    }
  }
}

extension ProfileSection {
  var headerTitle: String? {
    switch self {
    case .profileSetupHelper: return "새 프로필"
    case .favors: return "취향"
    case .anniversaries: return "기념일"
    case .memo: return "메모"
    case .friends: return "친구"
    }
  }

  var rightButtonTitle: String? {
    switch self {
    case .anniversaries: return "더보기"
    case .friends: return "전체보기"
    default: return nil
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
    case .favors:
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
        height: .absolute(87)
      )
    }
  }

  public var group: FavorCompositionalLayout.Group {
    switch self {
    case .profileSetupHelper:
      return .custom(
        width: .estimated(250),
        height: .estimated(250),
        direction: .horizontal,
        numberOfItems: 2,
        spacing: .fixed(8)
      )
    case .favors:
      let innerGroup: FavorCompositionalLayout.Group = .flow(
        height: .absolute(32),
        numberOfItems: 3,
        spacing: .fixed(10)
      )
      return .list(
        height: .estimated(32),
        numberOfItems: 2,
        spacing: .fixed(10),
        innerGroup: innerGroup
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
      return .custom(
        width: .estimated(1),
        height: .absolute(87),
        direction: .horizontal,
        numberOfItems: 10,
        spacing: .fixed(26)
      )
    }
  }

  public var section: FavorCompositionalLayout.Section {
    let header = FavorCompositionalLayout.BoundaryItem.header(height: .estimated(32))
    let whiteBackground = FavorCompositionalLayout.DecorationItem.background(
      kind: ProfileElementKind.sectionWhiteBackground
    )
    let defaultInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 40, trailing: 20)

    switch self {
    case .profileSetupHelper:
      return .base(
        contentInsets: defaultInsets,
        orthogonalScrolling: .paging,
        boundaryItems: [header],
        decorationItems: [whiteBackground]
      )
    case .favors:
      return .base(
        contentInsets: defaultInsets,
        boundaryItems: [header],
        decorationItems: [whiteBackground]
      )
    case .anniversaries:
      return .base(
        spacing: 10,
        contentInsets: defaultInsets,
        boundaryItems: [header],
        decorationItems: [whiteBackground]
      )
    case .memo:
      return .base(
        contentInsets: defaultInsets,
        boundaryItems: [header],
        decorationItems: [whiteBackground]
      )
    case .friends:
      return .base(
        contentInsets: NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 66, trailing: 20),
        orthogonalScrolling: .continuous,
        boundaryItems: [FavorCompositionalLayout.BoundaryItem.header(height: .estimated(72))]
      )
    }
  }
}
