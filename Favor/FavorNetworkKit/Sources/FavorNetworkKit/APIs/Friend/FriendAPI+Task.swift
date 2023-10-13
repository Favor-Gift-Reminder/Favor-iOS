//
//  FriendAPI+Task.swift
//  Favor
//
//  Created by 김응철 on 2023/03/08.
//

import Foundation

import Moya

extension FriendAPI {
  public func getTask() -> Moya.Task {
    switch self {
    case .getAllFriends:
      return .requestPlain

    case .getFriend:
      return .requestPlain

    case .deleteFriend:
      return .requestPlain

    case .patchFriendMemo(let memo, _):
      return .requestParameters(
        parameters: [
          "memo": memo
        ],
        encoding: JSONEncoding.default
      )
      
    case .postFriend(let friendName, let friendMemo, _):
      return .requestParameters(
        parameters: [
          "friendName": friendName,
          "friendMemo": friendMemo
        ],
        encoding: JSONEncoding.default
      )
      
    case .postUserFriend(let userFriendNo):
      return .requestParameters(
        parameters: [
          "friendUserNo": userFriendNo
        ],
        encoding: JSONEncoding.default
      )
      
    case .getFriendGivenGifts:
      return .requestPlain
      
    case .getFriendReceivedGifts:
      return .requestPlain
      
    case .getFriendTotalGifts:
      return .requestPlain
    }
  }
}
