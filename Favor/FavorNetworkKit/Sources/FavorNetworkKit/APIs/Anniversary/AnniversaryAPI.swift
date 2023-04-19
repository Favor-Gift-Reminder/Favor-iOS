//
//  AnniversaryAPI.swift
//  Favor
//
//  Created by 이창준 on 2023/04/19.
//

import Foundation

import Moya

public enum AnniversaryAPI {
  /// 전체 기념일 조회
  case getAnniversaries

  /// 단일 기념일 조회
  /// - Parameters:
  ///   - anniversaryNo: 조회하는 기념일의 DB 넘버 - `Path`
  case getAnniversary(anniversaryNo: Int)

  /// 기념일 삭제
  /// - Parameters:
  ///   - 삭제하는 기념일의 DB 넘버 - `Path`
  case deleteAnniversary(anniversaryNo: Int)

  /// 기념일 수정
  /// ``` json
  /// // AnniversaryUpdateRequestDTO
  /// {
  ///   "anniversaryTitle": "제목,
  ///   "anniversaryDate": "1996-02-29",
  ///   "isPinned": false
  /// }
  /// ```
  /// - Parameters:
  ///   - dto: 수정하는 기념일에 대한 정보를 담은 `AnniversaryUpdateRequestDTO` - `Body`
  ///   - anniversaryNo: 수정하는 기념일의 DB 넘버 - `Path`
  case patchAnniversary(AnniversaryUpdateRequestDTO, anniversaryNo: Int)

  /// 기념일 생성
  /// ``` json
  /// {
  ///   "anniversaryTitle": "제목",
  ///   "anniversaryDate": "1996-02-29"
  /// }
  /// ```
  /// - Parameters:
  ///   - dto: 생성하는 기념일에 대한 정보를 담은 `AnniversaryRequestDTO` - `Body`
  ///   - userNo: 기념일을 생성하는 회원의 DB 넘버 - `Path`
  case postAnniversary(AnniversaryRequestDTO, userNo: Int)
}
