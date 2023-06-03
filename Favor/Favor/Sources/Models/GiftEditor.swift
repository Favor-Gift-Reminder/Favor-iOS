//
//  GiftEditor.swift
//  Favor
//
//  Created by 이창준 on 2023/06/03.
//

import UIKit

import FavorKit

public struct GiftEditor {
  let giftNo: Int
  var name: String
  var date: Date?
  var photoList: [UIImage?]
  var memo: String?
  var category: FavorCategory
  var emotion: String?
  var isPinned: Bool
  var friendList: [Friend]
  var isGiven: Bool

  /// 초기값이 있는 선물을 수정하기 위해 사용되는 생성자
  init(
    giftNo: Int,
    name: String,
    date: Date? = nil,
    photoList: [UIImage?] = [],
    memo: String? = nil,
    category: FavorCategory,
    emotion: String? = nil,
    isPinned: Bool,
    friendList: [Friend],
    isGiven: Bool
  ) {
    self.giftNo = giftNo
    self.name = name
    self.date = date
    self.photoList = photoList
    self.memo = memo
    self.category = category
    self.emotion = emotion
    self.isPinned = isPinned
    self.friendList = friendList
    self.isGiven = isGiven
  }

  /// 초기값이 없는 새로운 선물을 추가하기 위해 사용되는 생성자
  init() {
    self.giftNo = -1
    self.name = ""
    self.date = nil
    self.photoList = []
    self.memo = nil
    self.category = .etc
    self.emotion = nil
    self.isPinned = false
    self.friendList = []
    self.isGiven = true
  }
}

// MARK: - Convertions

extension GiftEditor {
  public func toModel() -> Gift {
    Gift(
      giftNo: self.giftNo,
      name: self.name,
      date: self.date,
      memo: self.memo,
      category: self.category,
      emotion: self.emotion,
      isPinned: self.isPinned,
      friendList: self.friendList,
      isGiven: self.isGiven
    )
  }
}

extension Gift {
  public func toEditor() -> GiftEditor {
    GiftEditor(
      giftNo: self.giftNo,
      name: self.name,
      date: self.date,
      memo: self.memo,
      category: self.category,
      emotion: self.emotion,
      isPinned: self.isPinned,
      friendList: self.friendList.toArray(),
      isGiven: self.isGiven
    )
  }
}
