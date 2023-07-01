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

    case let .patchFriendMemo(_, friendNo):
      return "/friends/\(friendNo)"

    case .postFriend(_, _, let userNo):
      return "/friends/\(userNo)"
      
    case .postUserFriend:
      return "/friends"
      
    case .getFriendGivenGifts(let friendNo):
      return "/friends/given-gifts/\(friendNo)"
      
    case .getFriendReceivedGifts(let friendNo):
      return "/friends/received-gifts/\(friendNo)"

    case .getFriendTotalGifts(let friendNo):
      return "/friends/total-gifts/\(friendNo)"
    }
  }
}
