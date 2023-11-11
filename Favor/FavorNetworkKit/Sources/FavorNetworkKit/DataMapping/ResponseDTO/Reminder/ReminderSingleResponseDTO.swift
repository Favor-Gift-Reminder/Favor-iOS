//
//  ReminderResponseDTO.swift
//  Favor
//
//  Created by 김응철 on 2023/03/09.
//

import Foundation

import FavorKit

public struct ReminderSingleResponseDTO: Decodable {
  public let reminderNo: Int
  public let reminderTitle: String
  public let reminderDate: Date
  public let reminderMemo: String?
  public let isAlarmSet: Bool
  public let alarmTime: Date?
  public let userNo: Int
  public let friendSimpleDto: FriendResponseDTO

  private enum CodingKeys: CodingKey {
    case alarmTime
    case friendSimpleDto
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
    self.friendSimpleDto = try container.decode(FriendResponseDTO.self, forKey: .friendSimpleDto)
    self.isAlarmSet = try container.decode(Bool.self, forKey: .isAlarmSet)
    self.reminderMemo = try container.decodeIfPresent(String.self, forKey: .memo)
    let reminderDateString = try container.decode(String.self, forKey: .reminderDate)
    let reminderDate = reminderDateString.toDate("yyyy-MM-dd") ?? .distantPast
    self.reminderDate = reminderDate
    self.reminderNo = try container.decode(Int.self, forKey: .reminderNo)
    self.reminderTitle = try container.decode(String.self, forKey: .reminderTitle)
    self.userNo = try container.decode(Int.self, forKey: .userNo)
  }
}
