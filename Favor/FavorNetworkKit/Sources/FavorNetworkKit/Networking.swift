//
//  Networking.swift
//  
//
//  Created by 이창준 on 2023/03/10.
//

import OSLog

import FavorKit
import Moya
import RxMoya
import RxSwift

public typealias AnniversaryNetworking = Networking<AnniversaryAPI>
public typealias FriendNetworking = Networking<FriendAPI>
public typealias GiftNetworking = Networking<GiftAPI>
public typealias ReminderNetworking = Networking<ReminderAPI>
public typealias UserNetworking = Networking<UserAPI>

public final class Networking<TargetType: BaseTargetType> {

  // MARK: - Properties

  private let provider: MoyaProvider<TargetType>
  private let keychain: KeychainManager

  // MARK: - Initializer

  public init() {
    let keychain = KeychainManager()
    self.keychain = keychain
    let authPlugin = AccessTokenPlugin { _ in
      guard
        let data = try? keychain.get(account: KeychainManager.Accounts.accessToken.rawValue),
        let decodedString = String(data: data, encoding: .utf8)
      else {
        os_log(.info, "No access token found in keychain. Please attempt sign in to retrieve one.")
        return ""
      }
      return decodedString
    }
    self.provider = MoyaProvider<TargetType>(plugins: [authPlugin])
  }
  
  // MARK: - Functions
  
  public func request(_ target: TargetType) -> Observable<Response> {
    let requestURL = "\(target.method.rawValue) \(target.path)"
    return self.provider.rx.request(target)
      .filterSuccessfulStatusCodes()
      .catch(self.handleInternetConnection)
      .catch(self.handleTimeOut)
      .catch(self.handleREST)
      .asObservable()
      .do(
        onNext: { _ in
          let message = "🌐 ✅ SUCCESS: \(requestURL)"
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
          case APIError.restError(_, _, _):
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
          let message = "🌐 🟡 SUBSCRIBED: \(requestURL)"
          os_log(.debug, "\(message)")
        }
      )
  }
}
