//
//  GiftPhotoAPI+Method.swift
//
//
//  Created by 김응철 on 10/30/23.
//

import Foundation

import Moya

extension GiftPhotoAPI {
  public func getMethod() -> Moya.Method {
    switch self {
    case .getGiftPhotos:
      return .get
    case .postGiftPhotos:
      return .post
    case .deleteGiftPhotos:
      return .delete
    }
  }
}
