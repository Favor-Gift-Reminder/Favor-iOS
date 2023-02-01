//
//  HomeSection.swift
//  Favor
//
//  Created by 이창준 on 2023/01/31.
//

import RxDataSources

enum HomeSectionItem {
  case upcomingCell(UpcomingCellReactor)
  case timelineCell(TimelineCellReactor)
}

enum HomeSection {
  case upcoming([HomeSectionItem])
  case timeline([HomeSectionItem])
}

extension HomeSection: SectionModelType {
  typealias Item = HomeSectionItem
  
  var items: [Item] {
    switch self {
    case .upcoming(let items):
      return items
    case .timeline(let items):
      return items
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
  
  init(original: HomeSection, items: [Item]) {
    switch original {
    case .upcoming:
      self = .upcoming(items)
    case .timeline:
      self = .timeline(items)
    }
  }
}
