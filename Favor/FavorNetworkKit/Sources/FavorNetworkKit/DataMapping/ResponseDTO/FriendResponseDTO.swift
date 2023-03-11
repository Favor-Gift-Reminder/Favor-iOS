//
//  FriendResponseDTO.swift
//  Favor
//
//  Created by 김응철 on 2023/03/09.
//

import Foundation

enum FriendResponseDTO {
  
  /// 전체 친구
  public struct AllFriends: Decodable {
    let friendName: String
    let friendNo: Int
    let isUser: Bool
  }
  
  /// 단일 친구
  public struct Friend: Decodable {
    let favorList: [String]
    let friendMemo: String
    let friendName: String
    let friendNo: Int
    let isUser: Int
    let reminderList: [ReminderResponseDTO.AllReminders]
    let userFrinedNo: Int
    let userNo: Int
  }
}
