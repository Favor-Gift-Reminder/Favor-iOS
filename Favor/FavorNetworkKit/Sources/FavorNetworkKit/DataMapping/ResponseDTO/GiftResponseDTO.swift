//
//  GiftResponseDTO.swift
//  Favor
//
//  Created by 김응철 on 2023/03/09.
//

import Foundation

public struct GiftResponseDTO: Decodable {
  public let category: String // Enum
  public let emotion: String // Enum
  public let friendList: [FriendResponseDTO]
  public let giftDate: Date
  public let giftMemo: String
  public let giftName: String
  public let giftNo: Int
  public let isGive: Bool
  public let isPinned: Bool
  public let userNo: Int
}
