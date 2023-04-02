//
//  GiftResponseDTO.swift
//  Favor
//
//  Created by 김응철 on 2023/03/09.
//

import Foundation

public enum GiftResponseDTO {
  
  /// 전체 선물
  public struct AllGifts: Decodable {
    public let giftNo: Int
    public let isPinned: Bool
  }
  
  /// 단일 선물
  public struct Gift: Decodable {
    public let category: String
    public let emotion: String
    public let friendNo: Int
    public let giftDate: String
    public let giftMemo: String
    public let giftName: String
    public let giftNo: Int
    public let isGiven: Bool
    public let isPinned: Bool
    public let userNo: Int
  }
}
