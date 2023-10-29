//
//  GiftRequestModel.swift
//  Favor
//
//  Created by 김응철 on 2023/03/08.
//

import FavorKit

public struct GiftRequestDTO: Encodable {
  let giftName: String
  let giftDate: String
  let giftMemo: String
  let giftCategory: String
  let emotion: String
  let isPinned: Bool
  let isGiven: Bool
  let friendNoList: [Int]
  let tempFriendList: [String]
  
  public init(
    giftName: String,
    giftDate: String,
    giftMemo: String,
    category: FavorCategory,
    emotion: FavorEmotion,
    isPinned: Bool = false,
    isGiven: Bool = false,
    friendNoList: [Int],
    tempFriendList: [String]
  ) {
    self.giftName = giftName
    self.giftDate = giftDate
    self.giftMemo = giftMemo
    self.giftCategory = category.rawValue
    self.emotion = emotion.rawValue
    self.isPinned = isPinned
    self.isGiven = isGiven
    self.friendNoList = friendNoList
    self.tempFriendList = tempFriendList
  }
}
