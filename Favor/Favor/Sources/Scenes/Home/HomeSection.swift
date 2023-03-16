//
//  HomeSection.swift
//  Favor
//
//  Created by 이창준 on 2023/01/31.
//

import UIKit

import RxDataSources

enum HomeSectionType: Equatable {
  case upcoming
  case timeline
}

struct HomeSection {
  typealias HomeSectionModel = SectionModel<HomeSectionType, HomeSectionItem>

  enum HomeSectionItem: Equatable {
    case empty(UIImage?, String)
    case upcoming(UpcomingCellReactor)
    case timeline(TimelineCellReactor)

    static func == (lhs: HomeSection.HomeSectionItem, rhs: HomeSection.HomeSectionItem) -> Bool {
      switch (lhs, rhs) {
      case (.empty, .empty), (.upcoming, .upcoming), (.timeline, .timeline):
        return true
      default:
        return false
      }
    }
  }
}

extension HomeSectionType {
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
    case .upcoming: return 1
    case .timeline: return 2
    }
  }

  var spacing: CGFloat {
    switch self {
    case .upcoming: return 10.0
    case .timeline: return 5.0
    }
  }

  var headerHeight: NSCollectionLayoutDimension {
    switch self {
    case .upcoming:
      return .estimated(40.0 + 32.0 + 16.0) // Top + Content + Bottom
    case .timeline:
      return .estimated(40.0 + 67.0 + 22.0) // Top + Content + Bottom
    }
  }
}
