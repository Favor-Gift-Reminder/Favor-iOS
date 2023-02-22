//
//  MyPageSection.swift
//  Favor
//
//  Created by 이창준 on 2023/02/12.
//

import UIKit

import RxDataSources

enum MyPageSectionItem {
  case giftStat(GiftStatCellReactor)
  case newProfile(NewProfileCellReactor)
  case favor(FavorCellReactor)
  case anniversary(AnniversaryCellReactor)
}

enum MyPageSection {
  case giftStat([MyPageSectionItem])
  case newProfile([MyPageSectionItem])
  case favor([MyPageSectionItem])
  case anniversary([MyPageSectionItem])
}

extension MyPageSection: SectionModelType {
  typealias Item = MyPageSectionItem
  
  var items: [MyPageSectionItem] {
    switch self {
    case .giftStat(let items):
      return items
    case .newProfile(let items):
      return items
    case .favor(let items):
      return items
    case .anniversary(let items):
      return items
    }
  }
  
  init(original: MyPageSection, items: [MyPageSectionItem]) {
    switch original {
    case .giftStat:
      self = .giftStat(items)
    case .newProfile:
      self = .newProfile(items)
    case .favor:
      self = .favor(items)
    case .anniversary:
      self = .anniversary(items)
    }
  }
  
  // TODO: Section 데이터에 주입
  var headerTitle: String? {
    switch self {
    case .giftStat: return nil
    case .newProfile: return "새 프로필"
    case .favor: return "취향"
    case .anniversary: return "기념일"
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
    case .giftStat:
      return .init(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(131)
      )
    case .newProfile:
      return .init(
        widthDimension: .absolute(250),
        heightDimension: .absolute(262)
      )
    case .favor:
      return .init(
        widthDimension: .estimated(60),
        heightDimension: .absolute(32)
      )
    case .anniversary:
      return .init(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(95)
      )
    }
  }
  
  var sectionInset: NSDirectionalEdgeInsets {
    switch self {
    case .giftStat: return .zero
    default: return .init(top: 0, leading: 20, bottom: 40, trailing: 20)
    }
  }
  
  var spacing: CGFloat {
    switch self {
    case .giftStat: return .zero
    case .newProfile: return 8.0
    case .favor: return 10.0
    case .anniversary: return 10.0
    }
  }
  
  var columns: Int {
    switch self {
    case .favor: return 3
    default: return 1
    }
  }
  
  var orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior {
    switch self {
    case .newProfile: return .groupPaging
    default: return .none
    }
  }
}
