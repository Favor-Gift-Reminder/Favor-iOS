//
//  Networking+Plugin.swift
//  Favor
//
//  Created by 이창준 on 6/28/23.
//

import Foundation

import Moya

// MARK: - JWTAuthorizable

public protocol JWTAuthorizable {
  var authorizationType: JWTAuthorizationType? { get }
}

// MARK: - JWTAuthorizationType

public enum JWTAuthorizationType {
  case accessToken
  case refreshToken

  public var value: String {
    switch self {
    case .accessToken:
      return "X-AUTH-TOKEN"
    case .refreshToken:
      return "NOT-YET-IMPLEMENTED" // TODO: 리프레쉬 토큰 추가 후 변경
    }
  }
}

public final class FavorJWTPlugin: PluginType {
  public typealias TokenClosure = (TargetType) -> String

  /// 헤더에 적용될 토큰을 리턴하는 클로저
  public let tokenClosure: TokenClosure

  /// FavorMoyaPlugin을 초기화하는 생성자입니다.
  /// - Parameters:
  ///   - tokenClosure: `<JWTAuthorizationType>: <token>` 헤더에 적용될 토큰을 리턴하는 클로저
  public init(_ tokenClosure: @escaping TokenClosure) {
    self.tokenClosure = tokenClosure
  }

  /// 헤더에 토큰을 추가하는 것으로 Request를 준비합니다.
  /// - Parameters:
  ///   - request: 헤더를 추가할 Request
  ///   - target: Request의 타겟
  /// - Returns: 토큰이 헤더로 추가된 `URLRequest`
  public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
    guard
      let authorizable = target as? JWTAuthorizable,
      let authorizationType = authorizable.authorizationType
    else { return request }

    var request = request
    request.addValue(self.tokenClosure(target), forHTTPHeaderField: authorizationType.value)

    return request
  }
}
