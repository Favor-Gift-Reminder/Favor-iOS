//
//  UserAPI.swift
//  Favor
//
//  Created by 김응철 on 2023/03/08.
//

import Foundation

import Moya

enum UserAPI {
  case getAllUsers
  case getUser(userNo: Int)
  case deleteUser(userNo: Int)
  case patchUser(name: String, userId: String, favorList: [String], userNo: Int)
  case getAllFriendList(userNo: Int)
  case getGiftByCategory(category: String, userNo: Int)
  case getGiftByEmotion(emotion: String, userNo: Int)
  case getGiftByName(giftName: String, userNo: Int)
  case getAllGifts(userNo: Int)
  case getUserId(userId: String)
  case patchProfile(userId: String, name: String, userNo: Int)
  case getAllReminderList(userNo: Int)
  case postSignUp(email: String, password: String)
}

extension UserAPI: BaseTargetType {
  var path: String { self.getPath() }
  var method: Moya.Method { self.getMethod() }
  var task: Moya.Task { self.getTask() }
}
