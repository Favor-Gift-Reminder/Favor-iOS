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
  let isGiven: Bool
  let isPinned: Bool
  
  init(
    giftName: String,
    giftDate: String,
    giftMemo: String,
    category: String,
    emotion: String,
    isGiven: Bool = false,
    isPinned: Bool = false
  ) {
    self.giftName = giftName
    self.giftDate = giftDate
    self.giftMemo = giftMemo
    self.category = category
    self.emotion = emotion
    self.isGiven = isGiven
    self.isPinned = isPinned
  }
}
