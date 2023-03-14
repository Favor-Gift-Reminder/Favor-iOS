//
//  Networking+NetworkError.swift
//  
//
//  Created by 김응철 on 2023/03/14.
//

import Foundation

import Alamofire
import Moya

extension Networking {
  static func convertToURLError(_ error: Error) -> URLError? {
    switch error {
    case let MoyaError.underlying(afError as AFError, _):
      fallthrough
    case let afError as AFError:
      return afError.underlyingError as? URLError
    case let urlError as URLError:
      return urlError
    default:
      return nil
    }
  }
  
  static func isNotConnection(_ error: Error) -> Bool {
    Self.convertToURLError(error)?.code == .notConnectedToInternet
  }
  
  static func isLostConnection(_ error: Error) -> Bool {
    switch error {
    case let AFError.sessionTaskFailed(error: posixError as POSIXError)
      where posixError.code == .ECONNABORTED:
      break
    case let MoyaError.underlying(urlError as URLError, _):
      guard urlError.code == .networkConnectionLost else { fallthrough }
      break
    default:
      return false
    }
    return true
  }
}
