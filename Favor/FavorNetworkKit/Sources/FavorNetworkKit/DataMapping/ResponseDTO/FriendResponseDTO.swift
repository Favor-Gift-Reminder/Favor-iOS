//
//  FriendResponseDTO.swift
//  Favor
//
//  Created by 김응철 on 2023/03/09.
//

import Foundation

public struct FriendResponseDTO: Decodable {
  public let anniversaryList: AnniversaryResponseDTO
  public let favorList: [String]
  public let friendMemo: String
  public let friendName: String
  public let friendNo: Int
  public let friendUserNo: Int
  public let giftList: [GiftResponseDTO]
  public let isUser: Bool
  public let reminderList: [ReminderResponseDTO]
  public let userNo: Int
}
