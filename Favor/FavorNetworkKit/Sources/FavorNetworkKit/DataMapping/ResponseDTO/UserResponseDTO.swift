//
//  UserResponseDTO.swift
//  Favor
//
//  Created by 김응철 on 2023/03/09.
//

import Foundation

public enum UserResponseDTO {
  
  /// 전체 회원
  public struct AllUsers: Decodable {
    public let name: String
    public let role: String
    public let userNo: Int
    public let userId: String
  }
  
  /// 단일 회원
  public struct User: Decodable {
    public let email: String
    public let favorList: [String]
    public let frinedList: [FriendResponseDTO.Friend]
    public let giftList: [GiftResponseDTO.Gift]
    public let name: String?
    public let reminderList: [ReminderResponseDTO.Reminder]
    public let role: String
    public let userNo: Int
    public let userId: String?
  }
}
