//
//  ReminderAPI+Path.swift
//  Favor
//
//  Created by 김응철 on 2023/03/08.
//

import Foundation

import Moya

extension ReminderAPI {
  public func getPath() -> String {
    switch self {
    case .getAllReminders:
      return "/reminders/admin"

    case .getReminder(let reminderNo):
      return "/reminders/\(reminderNo)"

    case .deleteReminder(let reminderNo):
      return "/reminders/\(reminderNo)"

    case .patchReminder(_, let reminderNo):
      return "/reminders/\(reminderNo)"
      
    case .postFriendReminder(let anniversaryNo):
      return "/reminders/\(anniversaryNo)"
      
    case .postReminder:
      return "/reminders/new"
    }
  }
}
