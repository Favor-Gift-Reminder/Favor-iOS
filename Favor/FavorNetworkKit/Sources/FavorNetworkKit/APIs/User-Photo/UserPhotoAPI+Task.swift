//
//  UserPhotoAPI+Task.swift
//
//
//  Created by 김응철 on 11/12/23.
//

import Foundation

import Moya

extension UserPhotoAPI {
  public func getTask() -> Moya.Task {
    switch self {
    case .postBackground(let file):
      return .uploadMultipart([file])
    case .postProfile(let file):
      return .uploadMultipart([file])
    }
  }
}
