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
  var baseURL: URL {
    URL(string: APIManager.mock.baseURL)! // TODO: 서버 배포에 맞는 baseURL로 교체
  }

  var sampleData: Data { Data() }
}
