//
//  ReminderUpdateRequestDTO.swift
//  Favor
//
//  Created by 이창준 on 2023/04/19.
//

import Foundation

public struct ReminderUpdateRequestDTO: Encodable {
  let title: String
  let reminderDate: Date
  let isAlarmSet: Bool
  let alarmTime: Date
  let reminderMemo: String

  public init(
    title: String,
    reminderDate: Date,
    isAlarmSet: Bool,
    alarmTime: Date,
    reminderMemo: String
  ) {
    self.title = title
    self.reminderDate = reminderDate
    self.isAlarmSet = isAlarmSet
    self.alarmTime = alarmTime
    self.reminderMemo = reminderMemo
  }
}
