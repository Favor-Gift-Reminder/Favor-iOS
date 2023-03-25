//
//  Fetcher.swift
//  Favor
//
//  Created by 이창준 on 2023/03/22.
//

import Foundation

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

  private let disposeBag = DisposeBag()

  /// 서버에서 데이터를 받아오는 클로저
  public var onRemote: (() -> Single<T>) = { return .never() }
  /// LocalDB에서 데이터를 Observable 타입으로 생성하여 반환하는 클로저
  public var onLocalByObservable: (() -> Observable<T>) = { return .empty() }
  /// LocalDB에서 데이터를 받아오는 클로저
  public var onLocal: (() -> T)?
  /// LocalDB를 업데이트 하는 클로저
  public var onLocalUpdate: ((T) -> Void) = { _ in return }

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
    guard let _onLocal = self.onLocal else {
      fatalError("Define onLocal() method before calling fetch()")
    }

    return .create { observer in
      // 로컬에 저장된 데이터를 방출하며 status를 inProgress로 설정합니다.
      observer.onNext((.inProgress, _onLocal()))

      // 서버로부터 데이터를 받아와 처리합니다.
      self.onRemote()
        // 성공했다면
        .subscribe(onSuccess: { data in
          // 로컬 데이터를 업데이트하고
          self.onLocalUpdate(data)

          // 로컬 데이터를 방출하며
          self.onLocalByObservable()
            .subscribe(onNext: {
              // status를 success로 설정합니다.
              observer.onNext((.success, $0))
            })
            .disposed(by: self.disposeBag)
          // 실패했다면
        }, onFailure: { _ in
          // 로컬 데이터를 그대로 방출하고 status를 failure로 설정합니다.
          observer.onNext((.failure, _onLocal()))
        })
        .disposed(by: self.disposeBag)
      return Disposables.create()
    }
  }
}
