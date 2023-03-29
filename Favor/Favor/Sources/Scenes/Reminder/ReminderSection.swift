//
//  ReminderSection.swift
//  Favor
//
//  Created by 이창준 on 2023/03/29.
//

import UIKit.UIImage

import RxDataSources

enum ReminderSectionType {

}

struct ReminderSection {
  typealias ReminderSectionModel = SectionModel<ReminderSectionType, ReminderSectionItem>

  enum ReminderSectionItem {
    case empty(UIImage?, String)
  }
}

extension ReminderSectionType {
  
}
