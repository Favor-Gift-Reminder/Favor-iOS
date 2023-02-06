//
//  HomeSection.swift
//  Favor
//
//  Created by 이창준 on 2023/01/31.
//

import UIKit

import RxDataSources

enum HomeSectionItem {
  case emptyCell
  case upcomingCell(UpcomingCellReactor)
  case timelineCell(TimelineCellReactor)
}

enum HomeSection {
  case upcoming([HomeSectionItem])
  case timeline([HomeSectionItem])
}

extension HomeSection: SectionModelType, Equatable {
  typealias Item = HomeSectionItem
  
  var sectionIndex: Int {
    switch self {
    case .upcoming:
      return 0
    case .timeline:
      return 1
    }
  }
  
  var items: [Item] {
    switch self {
    case .upcoming(let items):
      return items
    case .timeline(let items):
      return items
    }
  }
  
  init(original: HomeSection, items: [Item]) {
    switch original {
    case .upcoming:
      self = .upcoming(items)
    case .timeline:
      self = .timeline(items)
    }
  }
  
  static func == (lhs: HomeSection, rhs: HomeSection) -> Bool {
    return lhs.sectionIndex == rhs.sectionIndex
  }
}

// MARK: - UI Constants

extension HomeSection {
  var cellSize: NSCollectionLayoutSize {
    switch self {
    case .upcoming:
      return NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(95.0)
      )
    case .timeline:
      return NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(0.5),
        heightDimension: .fractionalWidth(0.5)
      )
    }
  }
  
  var columns: Int {
    switch self {
    case .upcoming:
      return 1
    case .timeline:
      return 2
    }
  }
  
  var spacing: CGFloat {
    switch self {
    case .upcoming:
      return 10.0
    case .timeline:
      return 5.0
    }
  }
  
  var headerHeight: NSCollectionLayoutDimension {
    switch self {
    case .upcoming:
      return .estimated(32.0 + 26.0 + 16.0) // Top + Font + Bottom
    case .timeline:
      return .estimated(32.0 + 63.0 + 16.0) // Top + Content + Bottom
    }
  }
}
