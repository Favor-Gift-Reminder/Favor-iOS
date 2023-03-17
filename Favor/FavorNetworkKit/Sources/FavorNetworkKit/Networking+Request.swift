//
//  Networking+Request.swift
//  
//
//  Created by 김응철 on 2023/03/14.
//

import Moya
import RxSwift

extension Networking {
  public func handleInternetConnection<T: Any>(_ error: Error) throws -> Single<T> {
    guard
      let urlError = Self.convertToURLError(error),
      Self.isNotConnection(error)
    else { throw error }
    throw APIError.internetConnection(urlError)
  }
  
  public func handleTimeOut<T: Any>(_ error: Error) throws -> Single<T> {
    guard
      let urlError = Self.convertToURLError(error),
      urlError.code == .timedOut
    else { throw error }
    throw APIError.timeOut(urlError)
  }

  public func handleREST<T: Any>(_ error: Error) throws -> Single<T> {
    guard error is APIError else {
      throw APIError.restError(
        error,
        statusCode: (error as? MoyaError)?.response?.statusCode,
        errorCode: (try? (error as? MoyaError)?
          .response?
          .mapJSON() as? [String: Any])?["responseCode"] as? String
      )
    }
    throw error
  }
}
