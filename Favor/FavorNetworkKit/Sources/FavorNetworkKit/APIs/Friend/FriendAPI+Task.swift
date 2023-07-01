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

    case .patchFriend(let friendName, let friendMemo, _):
      return .requestParameters(
        parameters: [
          "friendName": friendName,
          "friendMemo": friendMemo
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
          "userFriendNo": userFriendNo
        ],
        encoding: JSONEncoding.default
      )
    }
  }
}
