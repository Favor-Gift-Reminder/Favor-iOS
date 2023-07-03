//
//  ReminderAPI+Method.swift
//  Favor
//
//  Created by 김응철 on 2023/03/08.
//

import Foundation

import Moya

extension ReminderAPI {
  public func getMethod() -> Moya.Method {
    switch self {
    case .getAllReminders:
      return .get

    case .getReminder:
      return .get

    case .deleteReminder:
      return .delete

    case .patchReminder:
      return .patch
      
    case .postFriendReminder:
      return .post
      
    case .postReminder:
      return .post
    }
  }
}
