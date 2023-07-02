//
//  FriendAPI+Method.swift
//  Favor
//
//  Created by 김응철 on 2023/03/08.
//

import Foundation

import Moya

extension FriendAPI {
  public func getMethod() -> Moya.Method {
    switch self {
    case .getAllFriends:
      return .get

    case .getFriend:
      return .get

    case .deleteFriend:
      return .delete

    case .patchFriendMemo:
      return .patch

    case .postFriend:
      return .post

    case .postUserFriend:
      return .post
      
    case .getFriendGivenGifts:
      return .get
      
    case .getFriendReceivedGifts:
      return .get
      
    case .getFriendTotalGifts:
      return .get
    }
  }
}
