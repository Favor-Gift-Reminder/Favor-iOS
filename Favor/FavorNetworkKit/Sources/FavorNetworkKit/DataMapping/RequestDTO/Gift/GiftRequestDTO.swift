//
//  GiftRequestModel.swift
//  Favor
//
//  Created by 김응철 on 2023/03/08.
//

import Foundation

public struct GiftRequestDTO: Encodable {
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
    category: String,
    emotion: String,
    isPinned: Bool = false,
    isGiven: Bool = false,
    friendNoList: [Int]
  ) {
    self.giftName = giftName
    self.giftDate = giftDate
    self.giftMemo = giftMemo
    self.category = category
    self.emotion = emotion
    self.isPinned = isPinned
    self.isGiven = isGiven
    self.friendNoList = friendNoList
  }
}
