//
//  ReminderUpdateRequestDTO.swift
//  Favor
//
//  Created by 이창준 on 2023/04/19.
//

import Foundation

public struct ReminderUpdateRequestDTO: Encodable {
  let title: String
  let reminderDate: String
  let isAlarmSet: Bool
  let alarmTime: String
  let friendNo: Int?
  let reminderMemo: String

  public init(
    title: String,
    reminderDate: String,
    isAlarmSet: Bool,
    alarmTime: String,
    friendNo: Int?,
    reminderMemo: String
  ) {
    self.title = title
    self.reminderDate = reminderDate
    self.isAlarmSet = isAlarmSet
    self.alarmTime = alarmTime
    self.friendNo = friendNo
    self.reminderMemo = reminderMemo
  }
}
