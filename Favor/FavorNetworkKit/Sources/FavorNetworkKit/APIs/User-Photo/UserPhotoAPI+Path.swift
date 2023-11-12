//
//  UserPhotoAPI+Path.swift
//
//
//  Created by 김응철 on 11/12/23.
//

import Foundation

extension UserPhotoAPI {
  public func getPath() -> String {
    switch self {
    case .postBackground:
      return "/user-photos/background"
    case .postProfile:
      return "/user-photos/profile"
    }
  }
}
