//
//  UserResponseDTO.swift
//  Favor
//
//  Created by 김응철 on 2023/03/09.
//

import Foundation

public struct UserResponseDTO: Decodable {
  public let anniversaryList: [AnniversaryResponseDTO]
  public let email: String
  public let favorList: [String] // [Enum]
  public let friendList: [FriendResponseDTO]
  public let giftList: [GiftResponseDTO]
  public let name: String
  public let reminderList: [ReminderResponseDTO]
  public let role: String // Enum
  public let userNo: Int
  public let userID: String
}
