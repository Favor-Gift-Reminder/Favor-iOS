//
//  AnniversaryAPI+Task.swift
//  Favor
//
//  Created by 이창준 on 2023/04/19.
//

import Foundation

import Moya

extension AnniversaryAPI {
  public func getTask() -> Moya.Task {
    switch self {
    case .getAnniversaries:
      return .requestPlain

    case .getAnniversary:
      return .requestPlain

    case .deleteAnniversary:
      return .requestPlain

    case let .patchAnniversary(anniversaryUpdateRequestDTO, anniversaryNo):
      return .requestCompositeParameters(
        bodyParameters: anniversaryUpdateRequestDTO.toDictionary(),
        bodyEncoding: JSONEncoding.default,
        urlParameters: [
          "anniversaryNo": anniversaryNo
        ]
      )
      
    case let .postAnniversary(anniversaryRequestDTO):
      return .requestJSONEncodable(anniversaryRequestDTO)
    }
  }
}
