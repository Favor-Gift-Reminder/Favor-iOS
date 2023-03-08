//
//  GiftAPI.swift
//  Favor
//
//  Created by 김응철 on 2023/03/08.
//

import Foundation

import Moya

enum GiftAPI {
  case getAllGifts
  case getGift(giftNo: Int)
  case deleteGift(giftNo: Int)
  case patchGift(GiftRequestDTO, friendNo: Int, giftNo: Int)
  case postGift(GiftRequestDTO, friendNo: Int, userNo: Int)
}

extension GiftAPI: BaseTargetType {
  var path: String { self.getPath() }
  var method: Moya.Method { self.getMethod() }
  var task: Moya.Task { self.getTask() }
}
