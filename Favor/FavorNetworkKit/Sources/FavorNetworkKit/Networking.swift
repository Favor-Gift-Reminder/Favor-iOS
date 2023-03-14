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
    self.provider = provider
  }
  
  // MARK: - Functions
  
  public func request(
    _ target: TargetType
  ) -> Single<Response> {
    let requestURL = "\(target.method.rawValue) \(target.path)"
    return self.provider.rx.request(target)
      .filterSuccessfulStatusCodes()
      .catch(self.handleInternetConnection)
      .catch(self.handleTimeOut)
      .catch(self.handleREST)
      .do(
        onSuccess: { value in
          let message = "🌐 ⭕ SUCCESS: \(requestURL) [\(value.statusCode)]"
          os_log(.debug, "\(message)")
        },
        onError: { error in
          switch error {
          case APIError.internetConnection:
            // 인터넷이 끊겼을 때,
            break
          case APIError.timeOut:
            // 요청 시간이 초과됐을 때,
            break
          case let APIError.restError(_, statusCode, errorCode):
            // statusCode가 200..<300 이외의 Response
            break
          default:
            // 다른 에러
            break
          }
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
