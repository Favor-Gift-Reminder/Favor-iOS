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

    // 로컬에 저장된 데이터를 방출하며 status를 inProgress로 설정합니다.
    onNext(.inProgress, _onLocal())

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
            onNext(.success, $0)
          })
          .disposed(by: disposeBag)
      // 실패했다면
      }, onFailure: { _ in
        // 로컬 데이터를 그대로 방출하고 status를 failure로 설정합니다.
        onNext(.failure, _onLocal())
      })
      .disposed(by: disposeBag)
  }
}
