//
//  GiftAPI+Method.swift
//  Favor
//
//  Created by 김응철 on 2023/03/08.
//

import Foundation

import Moya

extension GiftAPI {
  public func getMethod() -> Moya.Method {
    switch self {
    case .getAllGifts:
      return .get

    case .getGift:
      return .get

    case .deleteGift:
      return .delete

    case .patchGift:
      return .patch
      
    case .postGift:
      return .post
      
    case .patchPinGift:
      return .patch
    }
  }
}
