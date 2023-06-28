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
  private let keychain = KeychainManager()

  // MARK: - Initializer

  public init() {
    #if DEBUG
    var plugins: [PluginType] = [NetworkLoggerPlugin()]
    #else
    var plugins: [PluginType] = []
    #endif
    if let accessToken = try? self.keychain.get(account: KeychainManager.Accounts.accessToken.rawValue) {
      let accessTokenString = String(decoding: accessToken, as: UTF8.self)
      plugins.append(FavorJWTPlugin { _ in accessTokenString })
    }
    self.provider = MoyaProvider<TargetType>(plugins: plugins)
  }
  
  // MARK: - Functions
  
  public func request(_ target: TargetType) -> Observable<Response> {
    let requestURL = "\(target.method.rawValue) \(target.path)"
    return self.provider.rx.request(target)
      .catch(self.handleInternetConnection)
      .catch(self.handleTimeOut)
      .do(onSuccess: { _ in
        let message = "🌐 ✅ SUCCESS: \(requestURL)"
        os_log(.debug, "\(message)")
      }, onError: { error in
        if let response = (error as? MoyaError)?.response {
          let message = "🌐 ❌ FAILURE: \(requestURL) [\(response.statusCode)]"
          os_log(.error, "\(message)")
        }
      }, onSubscribed: {
        let message = "🌐 🟡 SUBSCRIBED: \(requestURL)"
        os_log(.debug, "\(message)")
      })
      .asObservable()
      .flatMap { response -> Observable<Response> in
        do {
          if let filteredResponse = try? response.filterSuccessfulStatusCodes() { // 200..<300
            return .just(filteredResponse)
          } else { // REST error
            let errorDTO: ErrorResponseDTO = try APIManager.decode(response.data)
            return .error(APIError.restError(
              responseCode: errorDTO.responseCode, responseMessage: errorDTO.responseMessage
            ))
          }
        } catch {
          return .error(error)
        }
      }
  }
}
