//
//  ReminderSection.swift
//  Favor
//
//  Created by 이창준 on 2023/03/29.
//

import UIKit.UIImage

import RxDataSources

enum ReminderSectionType {
  case upcoming
  case past
}

struct ReminderSection {
  typealias ReminderSectionModel = SectionModel<ReminderSectionType, ReminderSectionItem>

  enum ReminderSectionItem {
    case empty(UIImage?, String)
    case reminder(ReminderCellReactor)
  }
}

extension ReminderSectionType {
  var headerTitle: String {
    switch self {
    case .upcoming: return "다가오는 이벤트"
    case .past: return "지난 이벤트"
    }
  }

  var headerHeight: NSCollectionLayoutDimension {
    switch self {
    case .upcoming: return .estimated(80)
    case .past: return .estimated(130)
    }
  }
}
