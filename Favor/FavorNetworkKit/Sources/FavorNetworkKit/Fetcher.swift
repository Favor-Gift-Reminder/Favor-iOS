//
//  Fetcher.swift
//  Favor
//
//  Created by 이창준 on 2023/03/22.
//

import Foundation
import OSLog

import FavorKit
import Moya
import RealmSwift
import RxSwift

/// - T: LocalDB class
public class Fetcher<T> {

  // MARK: - Constants

  public enum Status {
    case inProgress, success, failure
  }

  // MARK: - Properties

  /// 서버에서 데이터를 받아오는 클로저
  public var onRemote: (() async throws -> Single<T>)?
  /// LocalDB에서 데이터를 받아오는 클로저
  public var onLocal: (() async throws -> T)?
  /// LocalDB를 업데이트 하는 클로저
  public var onLocalUpdate: ((_ local: T, _ remote: T) async throws -> Void)?

  // MARK: - Initializer

  public init() { }

  // MARK: - Functions

  /// 로컬 DB와 서버로부터 데이터를 `fetch`해옵니다.
  ///
  /// **로직 순서**
  /// 1. 로컬 DB로부터 데이터를 `read`하고 방출합니다. (`status` = `.inProgress`)
  /// 2. 서버에서부터 데이터를 `GET`해옵니다.
  /// 3. `request`가 성공했다면
  /// 4. 로컬 DB를 `response`를 적용하여 업데이트합니다.
  /// 5. 업데이트된 로컬 DB로부터 데이터를 `read`하고 방출합니다. (`status` = `.success`)
  /// 6. `request`가 실패했다면
  /// 7. 로컬 DB에 있는 데이터를 그대로 `read`하여 방출합니다. (`status` = `.failure`)
  public func fetch() -> Observable<(Status, T)> {
    guard
      let onRemote = self.onRemote,
      let onLocal = self.onLocal,
      let onLocalUpdate = self.onLocalUpdate
    else {
      fatalError("Failed to setup closures which are needed in fetch() method.")
    }

    return .create { observer in
      let task = _Concurrency.Task {
        do {
          // 로컬에 저장된 데이터를 방출하며 status를 inProgress로 설정합니다.
          os_log(.debug, "📂 🟡 FETCHER STATUS: inProgress")

          let localData = try await onLocal()
          observer.onNext((.inProgress, localData))

          do {
            let remoteData = try await onRemote().value
            os_log(.debug, "🌐 FETCHER GOT REMOTE DATA: \(String(describing: remoteData))")
            try await onLocalUpdate(localData, remoteData)

            observer.onNext((.success, try await onLocal()))
            os_log(.debug, "📂 🟢 FETCHER STATUS: success")
            observer.onCompleted()
          } catch {
            observer.onNext((.failure, localData))
            os_log(.error, "📂 🔴 FETCHER STATUS: failure")
          }
        } catch {
          observer.onError(error)
          os_log(.error, "📂 ❌ FETCHER STATUS: error")
        }
      }

      return Disposables.create {
        task.cancel()
      }
    }
  }
}
