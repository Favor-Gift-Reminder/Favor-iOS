//
//  AnniversaryAPI+Method.swift
//  Favor
//
//  Created by 이창준 on 2023/04/19.
//

import Foundation

import Moya

extension AnniversaryAPI {
  public func getMethod() -> Moya.Method {
    switch self {
    case .getAnniversaries:
      return .get

    case .getAnniversary:
      return .get

    case .deleteAnniversary:
      return .delete

    case .patchAnniversary:
      return .patch

    case .postAnniversary:
      return .post
      
    case .patchAnniversaryPin:
      return .patch
    }
  }
}
