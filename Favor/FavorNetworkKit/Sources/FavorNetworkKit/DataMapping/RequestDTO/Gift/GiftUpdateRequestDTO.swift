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
  let giftCategory: String
  let emotion: String
  let isGiven: Bool
  let friendNoList: [Int]

  public init(
    giftName: String,
    giftDate: String,
    giftMemo: String,
    category: FavorCategory,
    emotion: FavorEmotion,
    isGiven: Bool,
    friendNoList: [Int]
  ) {
    self.giftName = giftName
    self.giftDate = giftDate
    self.giftMemo = giftMemo
    self.giftCategory = category.rawValue
    self.emotion = emotion.rawValue
    self.isGiven = isGiven
    self.friendNoList = friendNoList
  }
}
