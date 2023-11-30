//
//  Networking.swift
//  
//
//  Created by 이창준 on 2023/03/10.
//

import OSLog
import UIKit

import FavorKit
import Moya
import RxMoya
import RxSwift

public typealias AnniversaryNetworking = Networking<AnniversaryAPI>
public typealias FriendNetworking = Networking<FriendAPI>
public typealias GiftNetworking = Networking<GiftAPI>
public typealias GiftPhotoNetworking = Networking<GiftPhotoAPI>
public typealias ReminderNetworking = Networking<ReminderAPI>
public typealias UserNetworking = Networking<UserAPI>
public typealias UserPhotoNetworking = Networking<UserPhotoAPI>

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
  
  @discardableResult
  public func request(
    _ target: TargetType,
    isOpeningPopup: Bool = true,
    loadingIndicator: Bool = false
  ) -> Observable<Response> {
    let requestURL = "\(target.method.rawValue) \(target.path)"
    return UIApplication.shared.topViewControllerAsObservable()
      .flatMap { topViewController -> Observable<Response> in
        guard let topViewController = topViewController as? BaseViewController else { return .empty() }
        if loadingIndicator { topViewController.isLoadingWillChange(true) }
        return self.provider.rx.request(target)
          .observe(on: MainScheduler.asyncInstance)
          .filterSuccessfulStatusCodes()
          .catch(self.handleInternetConnection)
          .catch(self.handleTimeOut)
          .catch(self.handleREST)
          .do(onSuccess: { _ in
            let message = "🌐 ✅ SUCCESS: \(requestURL)"
            os_log(.debug, "\(message)")
            topViewController.isLoadingWillChange(false)
          }, onError: { error in
            let message = "🌐 ❌ FAILURE: \(requestURL)"
            os_log(.error, "\(message)")
            if loadingIndicator { topViewController.isLoadingWillChange(false) }
            // Error Handling
            switch error {
            case APIError.timeOut:
              FavorNotificationManager.shared.showFavorPopup("요처시간이 초과되었습니다.")
            case APIError.internetConnection:
              // 인터넷 연결
              break
//              FavorNotificationManager.shared.showFavorPopup("인터넷 연결이 불안정합니다.")
            case let APIError.restError(_, responseMessage):
              // 서버 응답 오류
              if isOpeningPopup {
                FavorNotificationManager.shared.showFavorPopup(responseMessage)
              }
            case APIError.decodeError:
              // 디코딩 에러
              break
            default:
              break
            }
          }, onSubscribed: {
            let message = "🌐 🟡 SUBSCRIBED: \(requestURL)"
            os_log(.debug, "\(message)")
          })
          .asObservable()
      }
  }
}
