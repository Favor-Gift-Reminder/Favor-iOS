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
  case giftStats(FavorGiftStatsCellReactor)
  case setupProfile(FavorSetupProfileCellReactor)
  case prefers(FavorPrefersCellReactor)
  case anniversary(FavorAnniversaryCellReactor)
  case friend(FriendCellReactor)
}

enum MyPageSection {
  case giftStats([MyPageSectionItem])
  case setupProfile([MyPageSectionItem])
  case prefers([MyPageSectionItem])
  case anniversary([MyPageSectionItem])
  case friend([MyPageSectionItem])
}

extension MyPageSection: SectionModelType {
  typealias Item = MyPageSectionItem
  
  var items: [MyPageSectionItem] {
    switch self {
    case .giftStats(let items):
      return items
    case .setupProfile(let items):
      return items
    case .prefers(let items):
      return items
    case .anniversary(let items):
      return items
    case .friend(let items):
      return items
    }
  }
  
  init(original: MyPageSection, items: [MyPageSectionItem]) {
    switch original {
    case .giftStats:
      self = .giftStats(items)
    case .setupProfile:
      self = .setupProfile(items)
    case .prefers:
      self = .prefers(items)
    case .anniversary:
      self = .anniversary(items)
    case .friend:
      self = .friend(items)
    }
  }

  var headerTitle: String? {
    switch self {
    case .giftStats: return nil
    case .setupProfile: return "새 프로필"
    case .prefers: return "취향"
    case .anniversary: return "기념일"
    case .friend: return "친구"
    }
  }

  var headerRightItemTitle: String? {
    switch self {
    case .friend: return "전체보기"
    default: return nil
    }
  }
}

// MARK: - UI Constants

extension MyPageSection {
  var headerSize: NSCollectionLayoutSize {
    NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .absolute(40)
    )
  }
  
  var cellSize: NSCollectionLayoutSize {
    switch self {
    case .giftStats:
      return .init(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(131)
      )
    case .setupProfile:
      return .init(
        widthDimension: .absolute(250),
        heightDimension: .absolute(262)
      )
    case .prefers:
      return .init(
        widthDimension: .estimated(60),
        heightDimension: .absolute(32)
      )
    case .anniversary:
      return .init(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(95)
      )
    case .friend:
      return NSCollectionLayoutSize(
        widthDimension: .absolute(60),
        heightDimension: .absolute(85)
      )
    }
  }
  
  var sectionInset: NSDirectionalEdgeInsets {
    switch self {
    case .giftStats: return .zero
    default: return .init(top: 0, leading: 20, bottom: 40, trailing: 20)
    }
  }
  
  var spacing: CGFloat {
    switch self {
    case .giftStats: return .zero
    case .setupProfile: return 8.0
    case .prefers: return 10.0
    case .anniversary: return 10.0
    case .friend: return 26.0
    }
  }
  
  var columns: Int {
    switch self {
    case .prefers: return 5
    default: return 1
    }
  }
  
  var orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior {
    switch self {
    case .setupProfile: return .groupPaging
    case .friend: return .continuous
    default: return .none
    }
  }
  
  var widthStretchingDirection: ScrollDirection {
    switch self {
    case .prefers: return .horizontal
    default: return .vertical
    }
  }
}
