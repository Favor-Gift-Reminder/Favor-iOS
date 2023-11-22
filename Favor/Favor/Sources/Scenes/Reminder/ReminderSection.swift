//
//  ReminderSection.swift
//  Favor
//
//  Created by 이창준 on 2023/03/29.
//

import UIKit.UIImage

import RxDataSources

@MainActor
enum ReminderSectionType {
  case upcoming
  case past
}

struct ReminderSection {
  typealias ReminderSectionModel = SectionModel<ReminderSectionType, ReminderSectionItem>

  enum ReminderSectionItem {
    case reminder(ReminderCellReactor)
  }
}

extension ReminderSectionType {
  var headerTitle: String {
    switch self {
    case .upcoming: return "다가오는 기념일"
    case .past: return "지난 기념일"
    }
  }

  var headerHeight: NSCollectionLayoutDimension {
    switch self {
    case .upcoming: return .absolute(80)
    case .past: return .absolute(130)
    }
  }
}
