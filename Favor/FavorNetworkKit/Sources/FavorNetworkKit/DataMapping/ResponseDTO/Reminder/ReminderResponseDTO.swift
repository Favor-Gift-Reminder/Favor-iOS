//
//  File.swift
//  
//
//  Created by 김응철 on 11/11/23.
//

import Foundation

public struct ReminderResponseDTO: Decodable {
  public let reminderNo: Int
  public let reminderTitle: String
  public let reminderDate: Date
  public let userNo: Int
  public let alarmSet: Bool
  public let friendSimpleDto: FriendResponseDTO?
  
  enum CodingKeys: CodingKey {
    case reminderNo
    case reminderTitle
    case reminderDate
    case userNo
    case alarmSet
    case friendSimpleDto
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.reminderNo = try container.decode(Int.self, forKey: .reminderNo)
    self.reminderTitle = try container.decode(String.self, forKey: .reminderTitle)
    let reminderDateString = try container.decode(String.self, forKey: .reminderDate)
    self.reminderDate = reminderDateString.toDate("yyyy-MM-dd") ?? .distantPast
    self.userNo = try container.decode(Int.self, forKey: .userNo)
    self.friendSimpleDto = try container.decode(FriendResponseDTO?.self, forKey: .friendSimpleDto)
    self.alarmSet = try container.decode(Bool.self, forKey: .alarmSet)
  }
}
