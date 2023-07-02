//
//  UserAPI+Task.swift
//  Favor
//
//  Created by 김응철 on 2023/03/09.
//

import Foundation

import Moya

extension UserAPI {
  public func getTask() -> Moya.Task {
    switch self {
    case .getAllUsers:
      return .requestPlain

    case .getUser:
      return .requestPlain

    case .deleteUser:
      return .requestPlain

    case .patchUser(let name, let userId, let favorList):
      return .requestParameters(
        parameters: [
          "name": name,
          "userId": userId,
          "favorList": favorList
        ],
        encoding: JSONEncoding.default
      )
  
    case .getAllAnnivesaryList:
      return .requestPlain

    case .getAllFriendList:
      return .requestPlain

    case .getGiftByCategory:
      return .requestPlain

    case .getGiftByEmotion:
      return .requestPlain

    case .getGiftByName:
      return .requestPlain
      
    case .getGiftsGivenByUser:
      return .requestPlain
      
    case .getGiftsReceivedByUser:
      return .requestPlain

    case .getAllGifts:
      return .requestPlain

    case .getUserId:
      return .requestPlain

    case let .patchProfile(userId, name):
      return .requestParameters(
        parameters: [
          "userId": userId,
          "name": name
        ],
        encoding: JSONEncoding.default
      )

    case .getAllReminderList:
      return .requestPlain
      
    case .getAllFilterReminderList:
      return .requestPlain

    case let .postSignIn(email, password):
      return .requestParameters(
        parameters: [
          "email": email,
          "password": password
        ],
        encoding: JSONEncoding.default
      )

    case let .postSignUp(email, password):
      return .requestParameters(
        parameters: [
          "email": email,
          "password": password
        ],
        encoding: JSONEncoding.default
      )
    }
  }
}
