//
//  APIError.swift
//  
//
//  Created by 김응철 on 2023/03/14.
//

import Foundation

public enum APIError: Error {
  case internetConnection(Error)
  case timeOut(Error)
  case decodeError(Error)
  case restError(responseCode: String, responseMessage: String)

  public var description: String {
    switch self {
    case .decodeError(let error):
      return "💩 Decoding에 실패하였습니다.: \(error)"
    case let .restError(responseCode, responseMessage):
      return "\(responseCode): \(responseMessage)"
    default:
      return ""
    }
  }
}
