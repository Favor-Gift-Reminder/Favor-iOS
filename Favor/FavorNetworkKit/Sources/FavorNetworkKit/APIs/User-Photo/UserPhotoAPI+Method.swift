//
//  UserPhotoAPI+Method.swift
//  
//
//  Created by 김응철 on 11/12/23.
//

import Foundation

import Moya

extension UserPhotoAPI {
  public func getMethod() -> Moya.Method {
    switch self {
    case .postBackground, .postProfile:
      return .post
    }
  }
}
