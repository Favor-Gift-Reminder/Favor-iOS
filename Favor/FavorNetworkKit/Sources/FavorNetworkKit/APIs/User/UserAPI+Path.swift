//
//  UserAPI+Path.swift
//  Favor
//
//  Created by 김응철 on 2023/03/09.
//

import Foundation

import Moya

extension UserAPI {
  public func getPath() -> String {
    switch self {
    case .getAllUsers:
      return "/users/admin"

    case .getUser:
      return "/users"
      
    case .deleteUser:
      return "/users"

    case .patchUser:
      return "/users"
      
    case .getAllAnnivesaryList:
      return "/users/anniversaries"

    case .getAllFriendList:
      return "/users/friends"

    case .getGiftByCategory(let category):
      return "/users/gifts-by-category/\(category)"

    case .getGiftByEmotion(let emotion):
      return "/users/gifts-by-emotion/\(emotion)"

    case .getGiftByName(let giftName):
      return "/users/gifts-by-name/\(giftName)"
      
    case .getGiftsGivenByUser(let userNo):
      return "/users/gifts-given\(userNo)"
      
    case .getGiftsReceivedByUser(let userNo):
      return "/users/gifts-received/\(userNo)"

    case .getAllGifts:
      return "/users/gifts"

    case .getUserId(let userId):
      return "/users/\(userId)"

    case .patchProfile:
      return "/users/profile"

    case .getAllReminderList:
      return "/users/reminders"
      
    case let .getAllFilterReminderList(year, month):
      return "/users/reminders/\(year)/\(month)"

    case .postSignIn:
      return "/users/sign-in"

    case .postSignUp:
      return "/users/sign-up"
      
    case .patchPassword:
      return "/users/password"
    }
  }
}
