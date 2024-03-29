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
  ///   - anniversaryNo: 삭제하는 기념일의 DB 넘버 - `Path`
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
  case postAnniversary(AnniversaryRequestDTO)
  
  /// 기념일 핀 여부 수정
  /// - Parameters:
  ///  - annivesaryNo: 수정하는 기념일의 DB 넘버 - `Path`
  case patchAnniversaryPin(anniversaryNo: Int)
}

extension AnniversaryAPI: BaseTargetType {
  public var path: String { self.getPath() }
  public var method: Moya.Method { self.getMethod() }
  public var task: Moya.Task { self.getTask() }
}
