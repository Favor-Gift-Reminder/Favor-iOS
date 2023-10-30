//
//  GiftPhotoAPI+Task.swift
//
//
//  Created by 김응철 on 10/30/23.
//

import Foundation

import Moya

extension GiftPhotoAPI {
  public func getTask() -> Moya.Task {
    switch self {
    case .getGiftPhotos(let giftNo):
      return .requestParameters(
        parameters: ["giftNo": giftNo],
        encoding: URLEncoding.queryString
      )
      
    case let .postGiftPhotos(file, giftNo):
      return .requestCompositeData(
        bodyData: file,
        urlParameters: ["giftNo": giftNo]
      )
      
      
    case let .deleteGiftPhotos(fileUrl, giftNo):
      return .requestParameters(
        parameters: [
          "fileUrl": fileUrl,
          "giftNo": giftNo
        ],
        encoding: URLEncoding.queryString
      )
    }
  }
}
