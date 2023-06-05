//
//  FriendResponseDTO.swift
//  Favor
//
//  Created by 김응철 on 2023/03/09.
//

import Foundation

import FavorKit

public struct FriendResponseDTO: Decodable {
  public let anniversaryList: [AnniversaryResponseDTO]
  public let favorList: [String]
  public let friendMemo: String?
  public let friendName: String
  public let friendNo: Int
  public let friendUserNo: Int?
  public let giftList: [GiftResponseDTO]
  public let isUser: Bool
  public let reminderList: [ReminderResponseDTO]
  public let userNo: Int

  enum CodingKeys: CodingKey {
    case anniversaryList
    case favorList
    case friendMemo
    case friendName
    case friendNo
    case friendUserNo
    case giftList
    case isUser
    case reminderList
    case userNo
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.anniversaryList = try container.decode([AnniversaryResponseDTO].self, forKey: .anniversaryList)
    self.favorList = try container.decode([String].self, forKey: .favorList)
    self.friendMemo = try container.decodeIfPresent(String.self, forKey: .friendMemo)
    self.friendName = try container.decode(String.self, forKey: .friendName)
    self.friendNo = try container.decode(Int.self, forKey: .friendNo)
    self.friendUserNo = try container.decodeIfPresent(Int.self, forKey: .friendUserNo)
    self.giftList = try container.decode([GiftResponseDTO].self, forKey: .giftList)
    self.isUser = try container.decode(Bool.self, forKey: .isUser)
    self.reminderList = try container.decode([ReminderResponseDTO].self, forKey: .reminderList)
    self.userNo = try container.decode(Int.self, forKey: .userNo)
  }
}

// MARK: - Convert

extension FriendResponseDTO {
  public func toDomain() -> Friend {
    return Friend(
      friendNo: self.friendNo,
      name: self.friendName,
      anniversaryList: self.anniversaryList.map { $0.toDomain() },
      favorList: self.favorList,
      profilePhoto: nil,
      memo: self.friendMemo,
      friendUserNo: self.friendUserNo,
      isUser: self.isUser
    )
  }
}
