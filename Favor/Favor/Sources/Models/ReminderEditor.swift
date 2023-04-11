//
//  ReminderEditor.swift
//  Favor
//
//  Created by 이창준 on 2023/04/05.
//

import Foundation

import FavorKit

public struct ReminderEditor {
  var title: String = ""
  var date: Date = .now
  var memo: String?
  var shouldNotify: Bool = false
  var notifyTime: Date?
  var friend: Int = -1
}

extension Reminder {
  public func toDomain() -> ReminderEditor {
    ReminderEditor(
      title: self.title,
      date: self.date,
      shouldNotify: self.shouldNotify,
      friend: self.friendNo
    )
  }
}
