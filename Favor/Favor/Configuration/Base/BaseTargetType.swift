//
//  BaseTargetType.swift
//  Favor
//
//  Created by 이창준 on 2023/03/01.
//

import Foundation

import Moya

protocol BaseTargetType: TargetType { }

extension BaseTargetType {
  var baseURL: URL { URL(string: APIManager.mock.baseURL)! }
  var sampleData: Data { Data() }
  var headers: [String: String]? { return APIManager.header(for: .json) }
}
