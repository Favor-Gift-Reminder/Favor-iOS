//
//  MyPageSection.swift
//  Favor
//
//  Created by 이창준 on 2023/02/12.
//

import UIKit

import RxDataSources

enum MyPageSectionItem {
  case giftCount
  case newProfile
  case favor
  case anniversary
}

enum MyPageSection {
  case giftCount([MyPageSectionItem])
  case newProfile([MyPageSectionItem])
  case favor([MyPageSectionItem])
  case anniversary([MyPageSectionItem])
}

extension MyPageSection: SectionModelType {
  typealias Item = MyPageSectionItem
  
  var items: [MyPageSectionItem] {
    switch self {
    case .giftCount(let items):
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
    case .giftCount:
      self = .giftCount(items)
    case .newProfile:
      self = .newProfile(items)
    case .favor:
      self = .favor(items)
    case .anniversary:
      self = .anniversary(items)
    }
  }
}

// MARK: - UI Constants

extension MyPageSection {
  var cellSize: NSCollectionLayoutSize {
    switch self {
    case .giftCount:
      return .init(
        widthDimension: .estimated(46),
        heightDimension: .estimated(61)
      )
    case .newProfile:
      return .init(
        widthDimension: .estimated(250),
        heightDimension: .estimated(262)
      )
    case .favor:
      return .init(
        widthDimension: .estimated(60),
        heightDimension: .estimated(32)
      )
    case .anniversary:
      return .init(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(95)
      )
    }
  }
  
  var spacing: CGFloat {
    switch self {
    case .giftCount: return 72.0
    case .newProfile: return 8.0
    case .favor: return 10.0
    case .anniversary: return 10.0
    }
  }
  
  var columns: Int {
    switch self {
    case .giftCount: return 3
    case .newProfile: return 1
    case .favor: return 3
    case .anniversary: return 1
    }
  }
}
