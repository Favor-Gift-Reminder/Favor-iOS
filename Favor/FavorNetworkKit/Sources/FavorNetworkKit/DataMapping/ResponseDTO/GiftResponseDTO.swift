//
//  GiftResponseDTO.swift
//  Favor
//
//  Created by 김응철 on 2023/03/09.
//

import Foundation

import FavorKit

public struct GiftResponseDTO: Decodable {
  public let category: FavorCategory
  public let emotion: FavorEmotion
  public let friendList: [FriendResponseDTO]
  public let giftDate: Date
  public let giftMemo: String
  public let giftName: String
  public let giftNo: Int
  public let isGiven: Bool
  public let isPinned: Bool
  public let userNo: Int

  private enum CodingKeys: CodingKey {
    case category
    case emotion
    case friendList
    case giftDate
    case giftMemo
    case giftName
    case giftNo
    case isGiven
    case isPinned
    case userNo
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.category = try container.decode(FavorCategory.self, forKey: .category)
    self.emotion = try container.decode(FavorEmotion.self, forKey: .emotion)
    self.friendList = try container.decode([FriendResponseDTO].self, forKey: .friendList)
    let giftDateString = try container.decode(String.self, forKey: .giftDate)
    let giftDate = giftDateString.toDate("yyyy-MM-dd")
    self.giftDate = giftDate ?? .distantPast
    self.giftMemo = try container.decode(String.self, forKey: .giftMemo)
    self.giftName = try container.decode(String.self, forKey: .giftName)
    self.giftNo = try container.decode(Int.self, forKey: .giftNo)
    self.isGiven = try container.decode(Bool.self, forKey: .isGiven)
    self.isPinned = try container.decode(Bool.self, forKey: .isPinned)
    self.userNo = try container.decode(Int.self, forKey: .userNo)
  }
}
