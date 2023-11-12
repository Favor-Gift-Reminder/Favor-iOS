//
//  GiftPhotoAPI.swift
//
//
//  Created by 김응철 on 10/30/23.
//

import Foundation

import Moya

public enum GiftPhotoAPI {
  /// 선물 사진 목록 조회
  ///
  /// - Parameters:
  ///   - giftNo: 선물 식별자
  case getGiftPhotos(giftNo: Int)
  
  /// 선물 사진 추가
  ///
  /// - Parameters:
  ///   - file: 사진 `formData`형식의 파일
  ///   - giftNo: 선물 식별자
  case postGiftPhotos(file: MultipartFormData, giftNo: Int)
  
  /// 선물 사진 삭제
  ///
  /// - Parameters:
  ///   - fileUrl: 사진 URL
  ///   - giftNo: 선물 식별자
  case deleteGiftPhotos(fileUrl: String, giftNo: Int)
}

extension GiftPhotoAPI: BaseTargetType {
  public var path: String { self.getPath() }
  public var method: Moya.Method { self.getMethod() }
  public var task: Moya.Task { self.getTask() }
  public var headers: [String : String]? {
    switch self {
    case .postGiftPhotos:
      return APIManager.header(for: .multiPart)
    default:
      return APIManager.header(for: .json)
    }
  }
}
