//
//  UserResponseDTO.swift
//  Favor
//
//  Created by 김응철 on 2023/03/09.
//

import Foundation

public struct UserSingleResponseDTO: Decodable {
  public let anniversaryList: [AnniversarySingleResponseDTO]
  public let email: String
  public let favorList: [String] // [Enum]
  public let friendList: [FriendResponseDTO]
  public let name: String
  public let reminderList: [ReminderResponseDTO]
  public let role: String
  public let userNo: Int
  public let userID: String
  public let givenGift: Int
  public let receivedGift: Int
  public let totalGift: Int
  public let userBackgroundUserPhoto: PhotoResponseDTO?
  public let userProfileUserPhoto: PhotoResponseDTO?

  private enum CodingKeys: String, CodingKey {
    case anniversaryList
    case email
    case favorList
    case friendList
    case name
    case reminderList
    case role
    case userNo
    case userID = "userid"
    case givenGift
    case receivedGift
    case totalGift
    case userBackgroundUserPhoto
    case userProfileUserPhoto
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.anniversaryList = try container.decode([AnniversarySingleResponseDTO].self, forKey: .anniversaryList)
    self.email = try container.decode(String.self, forKey: .email)
    self.favorList = try container.decode([String].self, forKey: .favorList)
    self.friendList = try container.decode([FriendResponseDTO].self, forKey: .friendList)
    self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? "임시이름"
    self.reminderList = try container.decode([ReminderResponseDTO].self, forKey: .reminderList)
    self.role = try container.decode(String.self, forKey: .role)
    self.userNo = try container.decode(Int.self, forKey: .userNo)
    self.userID = try container.decodeIfPresent(String.self, forKey: .userID) ?? "임시아이디"
    self.givenGift = try container.decode(Int.self, forKey: .givenGift)
    self.receivedGift = try container.decode(Int.self, forKey: .receivedGift)
    self.totalGift = try container.decode(Int.self, forKey: .totalGift)
    self.userBackgroundUserPhoto = try container.decode(PhotoResponseDTO?.self, forKey: .userBackgroundUserPhoto)
    self.userProfileUserPhoto = try container.decode(PhotoResponseDTO?.self, forKey: .userProfileUserPhoto)
  }
}
