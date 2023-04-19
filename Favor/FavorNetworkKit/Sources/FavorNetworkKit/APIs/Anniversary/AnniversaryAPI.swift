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
  ///   - anniversaryNo: 수정하는 기념일의 DB 넘버 - `Path`
  case patchAnniversary(AnniversaryUpdateRequestDTO, anniversaryNo: Int)
}
