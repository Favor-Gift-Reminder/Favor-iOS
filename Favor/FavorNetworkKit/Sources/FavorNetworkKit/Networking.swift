//
//  Networking.swift
//  
//
//  Created by 이창준 on 2023/03/10.
//

import OSLog

import Moya
import RxMoya
import RxSwift

public typealias FriendNetworking = Networking<FriendAPI>
public typealias GiftNetworking = Networking<GiftAPI>
public typealias ReminderNetworking = Networking<ReminderAPI>
public typealias UserNetworking = Networking<UserAPI>

public final class Networking<TargetType: BaseTargetType> {

  // MARK: - Properties

  let provider: MoyaProvider<TargetType>

  // MARK: - Initializer

  public init() {
    let provider = MoyaProvider<TargetType>()
    provider.session.sessionConfiguration.timeoutIntervalForRequest = 10
    self.provider = provider
  }

  // MARK: - Functions

  public func request(
    _ target: TargetType
  ) -> Single<Response> {
    let requestURL = "\(target.method.rawValue) \(target.path)"
    return self.provider.rx.request(target)
      .filterSuccessfulStatusCodes()
      .do(
        onSuccess: { value in
          let message = "🌐 ⭕ SUCCESS: \(requestURL) [\(value.statusCode)]"
          os_log(.debug, "\(message)")
        },
        onError: { error in
          if let response = (error as? MoyaError)?.response {
            let message = "🌐 ❌ FAILURE: \(requestURL) [\(response.statusCode)]"
            os_log(.error, "\(message)")
          }
        },
        onSubscribed: {
          let message = "🌐 🟢 SUBSCRIBED: \(requestURL)"
          os_log(.debug, "\(message)")
        }
      )
  }
}
