//
//  ReminderRequestDTO.swift
//  Favor
//
//  Created by 김응철 on 2023/03/08.
//

import Foundation

public struct ReminderRequestDTO: Encodable {
  let reminderTitle: String
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
    self.reminderTitle = title
    self.reminderDate = reminderDate
    self.isAlarmSet = isAlarmSet
    self.alarmTime = alarmTime
    self.friendNo = friendNo
    self.reminderMemo = reminderMemo
  }
}
