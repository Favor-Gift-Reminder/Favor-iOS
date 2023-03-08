//
//  ReminderAPI.swift
//  Favor
//
//  Created by 김응철 on 2023/03/08.
//

import Foundation

import Moya

enum ReminderAPI {
  case getAllReminders
  case getReminder(reminderNo: Int)
  case deleteReminder(reminderNo: Int)
  case patchReminder(ReminderRequestDTO, friendNo: Int, reminderNo: Int)
  case postReminder(ReminderRequestDTO, friendNo: Int, userNo: Int)
}

extension ReminderAPI: BaseTargetType {
  var path: String { self.getPath() }
  var method: Moya.Method { self.getMethod() }
  var task: Moya.Task { self.getTask() }
}
