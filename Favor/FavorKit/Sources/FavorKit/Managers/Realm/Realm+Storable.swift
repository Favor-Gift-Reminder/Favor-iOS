//
//  Storable.swift
//  Favor
//
//  Created by 이창준 on 2023/06/05.
//

import class RealmSwift.Object

/// Realm 도메인과 UseCase 도메인 사이의 데이터 구조체를 변환하도록 도와주는
/// Wrapping Helper 프로토콜
public protocol Storable {
  associatedtype RealmObject: RealmSwift.Object
  associatedtype PropertyValue: PropertyValueType

  /// 데이터 모델의 식별자로 사용되는 프로퍼티
  var identifier: Int { get }

  init(realmObject: RealmObject)
  func realmObject() -> RealmObject
}

public typealias PropertyValuePair = (name: String, value: Any)

public protocol PropertyValueType {
  var propertyValuePair: PropertyValuePair { get }
}
