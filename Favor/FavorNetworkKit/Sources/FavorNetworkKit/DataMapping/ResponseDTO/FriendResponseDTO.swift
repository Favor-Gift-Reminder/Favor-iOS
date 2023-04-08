//
//  FriendResponseDTO.swift
//  Favor
//
//  Created by 김응철 on 2023/03/09.
//

import Foundation

public enum FriendResponseDTO {
  
  /// 전체 친구
  public struct AllFriends: Decodable {
    public let friendName: String
    public let friendNo: Int
    public let isUser: Bool
  }
  
  /// 단일 친구
  public struct Friend: Decodable {
    public let favorList: [String]
    public let friendMemo: String
    public let friendName: String
    public let friendNo: Int
    public let isUser: Int
    public let reminderList: [ReminderResponseDTO.AllReminders]
    public let userFrinedNo: Int
    public let userNo: Int
  }
}
