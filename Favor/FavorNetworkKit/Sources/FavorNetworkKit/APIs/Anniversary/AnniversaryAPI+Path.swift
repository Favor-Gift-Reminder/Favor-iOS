//
//  AnniversaryAPI+Path.swift
//  Favor
//
//  Created by 이창준 on 2023/04/19.
//

import Foundation

import Moya

extension AnniversaryAPI {
  public func getPath() -> String {
    switch self {
    case .getAnniversaries:
      return "/anniversaries/admin"

    case .getAnniversary(let anniversaryNo):
      return "/anniversaries/\(anniversaryNo)"

    case .deleteAnniversary(let anniversaryNo):
      return "/anniversaries/\(anniversaryNo)"

    case .patchAnniversary(_, let anniversaryNo):
      return "/anniversaries/\(anniversaryNo)"

    case .postAnniversary:
      return "/anniversaries"
      
    case .patchAnniversaryPin(let anniversaryNo):
      return "/anniversaries/pin/\(anniversaryNo)"
    }
  }
}
