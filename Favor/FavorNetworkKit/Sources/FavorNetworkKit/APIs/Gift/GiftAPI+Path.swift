//
//  GiftAPI+Path.swift
//  Favor
//
//  Created by 김응철 on 2023/03/08.
//

import Foundation

import Moya

extension GiftAPI {
  public func getPath() -> String {
    switch self {
    case .getAllGifts:
      return "/gifts/admin"

    case .getGift(let giftNo):
      return "/gifts/\(giftNo)"

    case .deleteGift(let giftNo):
      return "/gifts/\(giftNo)"

    case .patchGift(_, let giftNo):
      return "/gifts/\(giftNo)"
      
    case .postGift:
      return "/gifts"
      
    case .patchPinGift(let giftNo):
      return "/gifts/pin/\(giftNo)"
      
    case .patchTempFriendList(let giftNo, _):
      return "/gifts/temp-friend-list/\(giftNo)"
    }
  }
}
