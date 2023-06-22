//
//  GiftUpdateRequestDTO.swift
//  Favor
//
//  Created by 이창준 on 2023/04/19.
//

import Foundation

import FavorKit

public struct GiftUpdateRequestDTO: Encodable {
  let giftName: String
  let giftDate: String
  let giftMemo: String
  let category: String
  let emotion: String
  let isPinned: Bool
  let isGiven: Bool
  let friendNoList: [Int]

  public init(
    giftName: String,
    giftDate: String,
    giftMemo: String,
    category: FavorCategory,
    emotion: FavorEmotion,
    isPinned: Bool,
    isGiven: Bool,
    friendNoList: [Int]
  ) {
    self.giftName = giftName
    self.giftDate = giftDate
    self.giftMemo = giftMemo
    self.category = category.rawValue
    self.emotion = emotion.rawValue
    self.isPinned = isPinned
    self.isGiven = isGiven
    self.friendNoList = friendNoList
  }
}
