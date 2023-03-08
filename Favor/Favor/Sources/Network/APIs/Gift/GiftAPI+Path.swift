//
//  GiftAPI+Path.swift
//  Favor
//
//  Created by 김응철 on 2023/03/08.
//

import Foundation

import Moya

extension GiftAPI {
  func getPath() -> String {
    switch self {
    case .getAllGifts:
      return "/gifts"
    case .getGift(let giftNo):
      return "/gifts/\(giftNo)"
    case .deleteGift(let giftNo):
      return "/gifts/\(giftNo)"
    case .patchGift(_, _, let giftNo):
      return "/gifts/\(giftNo)"
    case .postGift(_, let friendNo, let userNo):
      return "/gifts/\(userNo)/\(friendNo)"
    }
  }
}
