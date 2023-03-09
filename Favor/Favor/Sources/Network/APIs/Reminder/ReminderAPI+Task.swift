//
//  ReminderAPI+Task.swift
//  Favor
//
//  Created by 김응철 on 2023/03/08.
//

import Foundation

import Moya

extension ReminderAPI {
  func getTask() -> Moya.Task {
    switch self {
    case .getAllReminders:
      return .requestPlain

    case .getReminder:
      return .requestPlain

    case .deleteReminder:
      return .requestPlain

    case .patchReminder(let reminderRequestDTO, let friendNo, _):
      return .requestCompositeParameters(
        bodyParameters: reminderRequestDTO.toDictionary(),
        bodyEncoding: JSONEncoding.default,
        urlParameters: [
          "friendNo": friendNo
        ]
      )
      
    case .postReminder(let reminderRequestDTO, _, _):
      return .requestJSONEncodable(reminderRequestDTO)
    }
  }
}
