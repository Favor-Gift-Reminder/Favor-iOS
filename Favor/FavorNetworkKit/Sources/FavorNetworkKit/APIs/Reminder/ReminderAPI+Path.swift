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
      return "/reminders"

    case .getReminder(let reminderNo):
      return "/reminders/\(reminderNo)"

    case .deleteReminder(let reminderNo):
      return "/reminders/\(reminderNo)"

    case .patchReminder(_, _, let reminderNo):
      return "/reminders/\(reminderNo)"
      
    case .postReminder(_, let friendNo, let userNo):
      return "/reminders/\(userNo)/\(friendNo)"
    }
  }
}
