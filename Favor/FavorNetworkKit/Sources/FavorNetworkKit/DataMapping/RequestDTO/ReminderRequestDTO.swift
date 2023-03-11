//
//  ReminderRequestDTO.swift
//  Favor
//
//  Created by 김응철 on 2023/03/08.
//

import Foundation

public struct ReminderRequestDTO: Encodable {
  let title: String
  let reminderDate: String
  let isAlarmSet: Bool
  let alarmTime: String
  let reminderMemo: String
}
