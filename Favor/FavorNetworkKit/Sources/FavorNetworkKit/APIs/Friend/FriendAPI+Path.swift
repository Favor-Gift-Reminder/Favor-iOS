//
//  FriendAPI+Path.swift
//  Favor
//
//  Created by 김응철 on 2023/03/08.
//

import Foundation

import Moya

extension FriendAPI {
  public func getPath() -> String {
    switch self {
    case .getAllFriends:
      return "/friends/admin"

    case .getFriend(let friendNo):
      return "/friends/\(friendNo)"

    case .deleteFriend(let friendNo):
      return "/friends/\(friendNo)"

    case .patchFriend(_, _, let friendNo):
      return "/friends/\(friendNo)"

    case .postFriend(_, _, let userNo):
      return "/friends/\(userNo)"
      
    case .postUserFriend:
      return "/friends"
    }
  }
}
