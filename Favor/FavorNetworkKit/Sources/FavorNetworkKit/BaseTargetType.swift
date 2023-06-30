//
//  BaseTargetType.swift
//  Favor
//
//  Created by 이창준 on 2023/03/01.
//

import Foundation

import FavorKit
import Moya

public protocol BaseTargetType: TargetType, JWTAuthorizable {
  func getPath() -> String
  func getMethod() -> Moya.Method
  func getTask() -> Moya.Task
}

extension BaseTargetType {
  public var baseURL: URL { URL(string: APIManager.v1.baseURL)! }
  public var sampleData: Data { Data() }
  public var headers: [String: String]? { return APIManager.header(for: .json) }
  public var authorizationType: JWTAuthorizationType? { return .accessToken }
}
