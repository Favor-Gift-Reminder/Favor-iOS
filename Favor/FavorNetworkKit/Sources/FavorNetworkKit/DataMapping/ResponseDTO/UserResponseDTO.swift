//
//  UserResponseDTO.swift
//  Favor
//
//  Created by 김응철 on 2023/03/09.
//

import Foundation

public struct UserResponseDTO: Decodable {
  public let anniversaryList: [AnniversaryResponseDTO]
  public let email: String
  public let favorList: [String] // [Enum]
  public let friendList: [FriendResponseDTO]
  public let giftList: [GiftResponseDTO]
  public let name: String
  public let reminderList: [ReminderResponseDTO]
  public let role: String // Enum
  public let userNo: Int
  public let userID: String

  private enum CodingKeys: CodingKey {
    case anniversaryList
    case email
    case favorList
    case friendList
    case giftList
    case name
    case reminderList
    case role
    case userNo
    case userID
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.anniversaryList = try container.decode([AnniversaryResponseDTO].self, forKey: .anniversaryList)
    self.email = try container.decode(String.self, forKey: .email)
    self.favorList = try container.decode([String].self, forKey: .favorList)
    self.friendList = try container.decode([FriendResponseDTO].self, forKey: .friendList)
    self.giftList = try container.decode([GiftResponseDTO].self, forKey: .giftList)
    self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? "임시이름"
    self.reminderList = try container.decode([ReminderResponseDTO].self, forKey: .reminderList)
    self.role = try container.decode(String.self, forKey: .role)
    self.userNo = try container.decode(Int.self, forKey: .userNo)
    self.userID = try container.decodeIfPresent(String.self, forKey: .userID) ?? "임시아이디"
  }
}
