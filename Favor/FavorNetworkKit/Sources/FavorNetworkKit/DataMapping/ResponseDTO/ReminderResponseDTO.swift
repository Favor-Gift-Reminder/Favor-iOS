//
//  ReminderResponseDTO.swift
//  Favor
//
//  Created by 김응철 on 2023/03/09.
//

import Foundation

public enum ReminderResponseDTO {
  
  /// 전체 리마인더
  public struct AllReminders: Decodable {
    public let eventDate: String
    public let friendNo: Int
    public let isAlarmSet: Bool
    public let reminderNo: Int
    public let title: String
    public let userNo: Int
  }
  
  /// 단일 리마인더
  public struct Reminder: Decodable {
    public let alarmTime: String
    public let friendNo: Int
    public let isAlarmSet: Bool
    public let memo: String
    public let reminderDate: String
    public let reminderNo: Int
    public let title: String
    public let userNo: Int
  }
}
