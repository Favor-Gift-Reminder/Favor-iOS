//
//  ReminderResponseDTO.swift
//  Favor
//
//  Created by 김응철 on 2023/03/09.
//

import Foundation

enum ReminderResponseDTO {
  
  /// 전체 리마인더
  public struct AllReminders: Decodable {
    let eventDate: String
    let friendNo: Int
    let isAlarmSet: Bool
    let reminderNo: Int
    let title: String
    let userNo: Int
  }
  
  /// 단일 리마인더
  public struct Reminder: Decodable {
    let alarmTime: String
    let friendNo: Int
    let isAlarmSet: Bool
    let memo: String
    let reminderDate: String
    let reminderNo: Int
    let title: String
    let userNo: Int
  }
}
