//
//  UserAPI+Method.swift
//  Favor
//
//  Created by 김응철 on 2023/03/09.
//

import Foundation

import Moya

extension UserAPI {
  public func getMethod() -> Moya.Method {
    switch self {
    case .getAllUsers:
      return .get

    case .getUser:
      return .get

    case .deleteUser:
      return .delete

    case .patchUser:
      return .patch
      
    case .getAllAnnivesaryList:
      return .get

    case .getAllFriendList:
      return .get

    case .getGiftByCategory:
      return .get

    case .getGiftByEmotion:
      return .get

    case .getGiftByName:
      return .get
      
    case .getGiftsGivenByUser:
      return .get
      
    case .getGiftsReceivedByUser:
      return .get

    case .getAllGifts:
      return .get

    case .getUserId:
      return .get

    case .patchProfile:
      return .patch

    case .getAllReminderList:
      return .get
      
    case .getAllFilterReminderList:
      return .get

    case .postSignIn:
      return .post

    case .postSignUp:
      return .post
      
    case .patchPassword:
      return .patch
    }
  }
}
