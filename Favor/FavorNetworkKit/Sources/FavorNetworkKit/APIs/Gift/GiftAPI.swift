//
//  GiftAPI.swift
//  Favor
//
//  Created by 김응철 on 2023/03/08.
//

import Foundation

import Moya

public enum GiftAPI {
  /// 전체 선물 조회
  case getAllGifts

  /// 단일 선물 조회
  /// - Parameters:
  ///   - giftNo: 조회하는 선물의 DB 넘버 - `Path`
  case getGift(giftNo: Int)

  /// 선물 삭제
  /// - Parameters:
  ///   - giftNo: 삭제하는 선물의 DB 넘버 - `Path`
  case deleteGift(giftNo: Int)
  
  /// 선물 수정
  /// ``` json
  /// // GiftUpdateRequestDTO
  /// {
  ///   "giftName": "선물이름",
  ///   "giftDate": "1996-02-29",
  ///   "giftMemo": "선물메모",
  ///   "category": "생일",
  ///   "emotion": "기뻐요",
  ///   "isPinned": false,
  ///   "isGiven": false,
  ///   "friendNoList": [1]
  /// }
  /// ```
  /// - Parameters:
  ///   - dto: 수정하는 선물의 정보를 담은 리퀘스트 DTO - `Body`
  ///   - giftNo: 수정하는 선물의 DB 넘버 - `Path`
  case patchGift(GiftUpdateRequestDTO, giftNo: Int)

  /// 선물 생성
  /// ``` json
  /// // giftRequestDTO
  /// {
  ///   "giftName": "선물이름",
  ///   "giftDate": "1996-02-29",
  ///   "giftMemo": "선물메모",
  ///   "category": "생일",
  ///   "emotion": "기뻐요",
  ///   "isGiven": false
  /// }
  /// ```
  /// - Parameters:
  ///   - dto: 생성하는 선물의 정보를 담은 리퀘스트 DTO - `Body`
  case postGift(GiftRequestDTO)
}

extension GiftAPI: BaseTargetType {
  public var path: String { self.getPath() }
  public var method: Moya.Method { self.getMethod() }
  public var task: Moya.Task { self.getTask() }
}
