//
//  UserAPI+Path.swift
//  Favor
//
//  Created by 김응철 on 2023/03/09.
//

import Foundation

import Moya

extension UserAPI {
  func getPath() -> String {
    switch self {
    case .getAllUsers:
      return "/users"
    case .getUser(let userNo):
      return "/users/\(userNo)"
    case .deleteUser(let userNo):
      return "/users/\(userNo)"
    case .patchUser(_, _, _, let userNo):
      return "/users/\(userNo)"
    case .getAllFriendList(let userNo):
      return "/users/friend-list/\(userNo)"
    case .getGiftByCategory(let category, let userNo):
      return "/users/gift-by-category/\(userNo)/\(category)"
    case .getGiftByEmotion(let emotion, let userNo):
      return "/users/gift-by-emotion/\(userNo)/\(emotion)"
    case .getGiftByName(let giftName, let userNo):
      return "/users/gift-by-name/\(userNo)/\(giftName)"
    case .getAllGifts(let userNo):
      return "/users/gift-list/\(userNo)"
    case .getUserId(let userId):
      return "/users/id/\(userId)"
    case .patchProfile:
      return "/users/profile"
    case .getAllReminderList(let userNo):
      return "/users/reminder-list/\(userNo)"
    case .postSignUp:
      return "/users/sign-up"
    }
  }
}
