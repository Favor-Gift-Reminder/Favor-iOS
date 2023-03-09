//
//  GiftResponseDTO.swift
//  Favor
//
//  Created by 김응철 on 2023/03/09.
//

import Foundation

enum GiftResponseDTO {
  
  /// 전체 선물
  struct AllGifts: Decodable {
    let giftNo: Int
    let isPinned: Bool
  }
  
  /// 단일 선물
  struct Gift: Decodable {
    let category: String
    let emotion: String
    let friendNo: Int
    let giftDate: String
    let giftMemo: String
    let giftName: String
    let giftNo: Int
    let isGiven: Bool
    let isPinned: Bool
    let userNo: Int
  }
}
