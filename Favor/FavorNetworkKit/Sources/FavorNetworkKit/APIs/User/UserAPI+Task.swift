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

    case .patchUser(let name, let userId, let favorList, _):
      return .requestParameters(
        parameters: [
          "name": name,
          "userId": userId,
          "favorList": favorList
        ],
        encoding: JSONEncoding.default
      )

    case .getAllFriendList:
      return .requestPlain

    case .getGiftByCategory:
      return .requestPlain

    case .getGiftByEmotion:
      return .requestPlain

    case .getGiftByName:
      return .requestPlain

    case .getAllGifts:
      return .requestPlain

    case .getUserId:
      return .requestPlain

    case let .patchProfile(userId, name, userNo):
      return .requestCompositeParameters(
        bodyParameters: [
          "userId": userId,
          "name": name
        ],
        bodyEncoding: JSONEncoding.default,
        urlParameters: [
          "userNo": userNo
        ]
      )

    case .getAllReminderList:
      return .requestPlain

    case .postSignUp(let email, let password):
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
