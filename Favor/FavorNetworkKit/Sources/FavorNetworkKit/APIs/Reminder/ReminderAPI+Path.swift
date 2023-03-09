//
//  ReminderAPI+Path.swift
//  Favor
//
//  Created by 김응철 on 2023/03/08.
//

import Foundation

import Moya

extension ReminderAPI {
  func getPath() -> String {
    switch self {
    case .getAllReminders:
      return "/reminders"

    case .getReminder(let reminderNo):
      return "/reminders/\(reminderNo)"

    case .deleteReminder(let reminderNo):
      return "/reminders/\(reminderNo)"

    case .patchReminder(let reminderRequestDTO, let friendNo, let reminderNo):
      return "/reminders/\(reminderNo)"
      
    case .postReminder(let reminderRequestDTO, let friendNo, let userNo):
      return "/reminders/\(userNo)/\(friendNo)"
    }
  }
}
