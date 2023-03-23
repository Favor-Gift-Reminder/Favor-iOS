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

  public func fetch(_ onNext: @escaping (Status, T) -> Void) {

    guard let _onLocal = self.onLocal else {
      fatalError("Define onLocal() method before calling fetch()")
    }

    let disposeBag = DisposeBag()

    onNext(.inProgress, _onLocal())

    self.onRemote()
      .subscribe(onSuccess: { data in
        self.onLocalUpdate(data)

        self.onLocalByObservable()
          .subscribe(onNext: {
            onNext(.success, $0)
          })
          .disposed(by: disposeBag)
      }, onFailure: { _ in
        onNext(.failure, _onLocal())
      })
      .disposed(by: disposeBag)
  }
}
