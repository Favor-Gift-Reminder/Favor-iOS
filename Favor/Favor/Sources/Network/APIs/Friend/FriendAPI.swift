//
//  FriendTarget.swift
//  Favor
//
//  Created by 김응철 on 2023/03/08.
//

import Foundation

import Moya

enum FriendAPI {
  case getAllFriends
  case getFriend(friendNo: Int)
  case deleteFriend(friendNo: Int)
  case patchFriend(friendName: String, friendMemo: String, friendNo: Int)
  case postFriend(friendName: String, friendMemo: String, userNo: Int)
  case postUserFriend(userFriendNo: Int, userFriendMemo: String, userNo: Int)
}

extension FriendAPI: BaseTargetType {
  var path: String { self.getPath() }
  var method: Moya.Method { self.getMethod() }
  var task: Moya.Task { self.getTask() }
}
