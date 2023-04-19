//
//  ReminderResponseDTO.swift
//  Favor
//
//  Created by 김응철 on 2023/03/09.
//

import Foundation

public struct ReminderResponseDTO: Decodable {
  public let alarmTime: Date?
  public let friendNo: Int
  public let isAlarmSet: Bool
  public let memo: String
  public let reminderDate: Date
  public let reminderNo: Int
  public let reminderTitle: String
  public let userNo: Int

  private enum CodingKeys: CodingKey {
    case alarmTime
    case friendNo
    case isAlarmSet
    case memo
    case reminderDate
    case reminderNo
    case reminderTitle
    case userNo
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let alarmTimeString = try container.decodeIfPresent(String.self, forKey: .alarmTime)
    let alarmTime = alarmTimeString?.toDate()
    self.alarmTime = alarmTime
    self.friendNo = try container.decode(Int.self, forKey: .friendNo)
    self.isAlarmSet = try container.decode(Bool.self, forKey: .isAlarmSet)
    self.memo = try container.decode(String.self, forKey: .memo)
    let reminderDateString = try container.decode(String.self, forKey: .reminderDate)
    let reminderDate = reminderDateString.toDate("yyyy-MM-dd") ?? .distantPast
    self.reminderDate = reminderDate
    self.reminderNo = try container.decode(Int.self, forKey: .reminderNo)
    self.reminderTitle = try container.decode(String.self, forKey: .reminderTitle)
    self.userNo = try container.decode(Int.self, forKey: .userNo)
  }
}
