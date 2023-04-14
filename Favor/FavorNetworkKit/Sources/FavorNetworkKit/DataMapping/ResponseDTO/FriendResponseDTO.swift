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
    public let isUser: Bool
    public let reminderList: [ReminderResponseDTO.Reminder]
    public let giftNoList: [Int]
    public let friendUserNo: Int
    public let userNo: Int
  }
}
