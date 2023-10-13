//
//  FriendSingleResponseDTO.swift
//  Favor
//
//  Created by 김응철 on 2023/03/09.
//

import Foundation

import FavorKit

public struct FriendSingleResponseDTO: Decodable {
  public let friendNo: Int
  public let friendName: String
  public let friendId: String
  public let friendMemo: String
  public let reminderList: [ReminderResponseDTO]
  public let favorList: [String]
  public let anniversaryList: [AnniversaryResponseDTO]
  public let givenGift: Int
  public let receivedGift: Int
  public let totalGift: Int
  public let userNo: Int
  
  enum CodingKeys: CodingKey {
    case friendNo
    case friendName
    case friendId
    case friendMemo
    case reminderList
    case favorList
    case anniversaryList
    case givenGift
    case receivedGift
    case totalGift
    case userNo
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.anniversaryList = try container.decode([AnniversaryResponseDTO].self, forKey: .anniversaryList)
    self.favorList = try container.decode([String].self, forKey: .favorList)
    self.friendMemo = try container.decode(String.self, forKey: .friendMemo)
    self.friendName = try container.decode(String.self, forKey: .friendName)
    self.friendId = try container.decode(String.self, forKey: .friendId)
    self.friendNo = try container.decode(Int.self, forKey: .friendNo)
    self.reminderList = try container.decode([ReminderResponseDTO].self, forKey: .reminderList)
    self.userNo = try container.decode(Int.self, forKey: .userNo)
    self.givenGift = try container.decode(Int.self, forKey: .givenGift)
    self.receivedGift = try container.decode(Int.self, forKey: .receivedGift)
    self.totalGift = try container.decode(Int.self, forKey: .totalGift)
  }
}
