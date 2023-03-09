//
//  UserResponseDTO.swift
//  Favor
//
//  Created by 김응철 on 2023/03/09.
//

import Foundation

enum UserResponseDTO {
  
  /// 전체 회원
  struct AllUsers: Decodable {
    let name: String
    let role: String
    let userNo: Int
    let userId: String
  }
  
  /// 단일 회원
  struct User: Decodable {
    let email: String
    let favorList: [String]
    let frinedList: [FriendResponseDTO.AllFriends]
    let giftList: [GiftResponseDTO.AllGifts]
    let name: String
    let reminderList: [ReminderResponseDTO.AllReminders]
    let role: String
    let userNo: Int
    let userId: String
  }
}
