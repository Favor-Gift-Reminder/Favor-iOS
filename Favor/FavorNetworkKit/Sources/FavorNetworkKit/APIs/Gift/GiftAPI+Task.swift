//
//  GiftAPI+Task.swift
//  Favor
//
//  Created by 김응철 on 2023/03/08.
//

import Foundation

import FavorKit
import Moya

extension GiftAPI {
  public func getTask() -> Moya.Task {
    switch self {
    case .getAllGifts:
      return .requestPlain

    case .getGift:
      return .requestPlain

    case .deleteGift:
      return .requestPlain

    case .patchGift(let giftRequestDTO, _):
      return .requestJSONEncodable(giftRequestDTO)
      
    case .postGift(let giftRequestDTO, _):
      return .requestJSONEncodable(giftRequestDTO)
    }
  }
}
