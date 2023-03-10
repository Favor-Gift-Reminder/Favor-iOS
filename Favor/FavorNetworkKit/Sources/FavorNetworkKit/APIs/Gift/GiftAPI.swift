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
  /// // giftRequestDTO
  /// {
  ///   "giftName": "선물이름",
  ///   "giftDate": "1996-02-29",
  ///   "giftMemo": "선물메모",
  ///   "category": "생일",
  ///   "emotion": "기뻐요",
  ///   "isPinned": false,
  ///   "isGiven": false
  /// }
  /// ```
  /// - Parameters:
  ///   - dto: 수정하는 선물의 정보를 담은 리퀘스트 DTO - `Body`
  ///   - friendNo: 수정하는 선물과 관련된 친구의 DB 넘버 - `Query`
  ///   - giftNo: 수정하는 선물의 DB 넘버 - `Path`
  case patchGift(GiftRequestDTO, friendNo: Int, giftNo: Int)

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
  ///   - friendNo: 생성하는 선물과 관련된 친구의 DB 넘버 - `Path`
  ///   - userNo: 선물을 생성하는 유저의 DB 넘버 - `Path`
  case postGift(GiftRequestDTO, friendNo: Int, userNo: Int)
}

extension GiftAPI: BaseTargetType {
  public var path: String { self.getPath() }
  public var method: Moya.Method { self.getMethod() }
  public var task: Moya.Task { self.getTask() }
}
