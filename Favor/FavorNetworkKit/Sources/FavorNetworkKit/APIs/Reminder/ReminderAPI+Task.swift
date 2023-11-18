//
//  ReminderAPI+Task.swift
//  Favor
//
//  Created by 김응철 on 2023/03/08.
//

import Foundation

import Moya

extension ReminderAPI {
  public func getTask() -> Moya.Task {
    switch self {
    case .getAllReminders:
      return .requestPlain

    case .getReminder:
      return .requestPlain

    case .deleteReminder:
      return .requestPlain

    case .patchReminder(let reminderRequestDTO, _):
      return .requestJSONEncodable(reminderRequestDTO)
      
    case .postFriendReminder:
      return .requestPlain
      
    case .postReminder(let reminderRequestDTO):
      return .requestJSONEncodable(reminderRequestDTO)
    }
  }
}
