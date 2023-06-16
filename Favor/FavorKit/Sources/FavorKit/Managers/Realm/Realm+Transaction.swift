//
//  Transaction.swift
//  Favor
//
//  Created by 이창준 on 6/6/23.
//

import struct RealmSwift.Realm
import class RealmSwift.Object

public final class Transaction {

  // MARK: - Properties

  private let realm: Realm

  // MARK: - Initializer

  internal init(realm: Realm) {
    self.realm = realm
  }

  // MARK: - Functions

  /// `Storable` 구조체를 받아 `write`합니다.
  public func create<T: Storable>(
    _ value: T,
    update: Realm.UpdatePolicy = .modified
  ) {
    self.realm.add(value.realmObject(), update: update)
  }

  /// `Storable` 구조체를 프로퍼티 단위로 업데이트 합니다.
  public func update<T: Storable>(
    _ type: T.Type,
    values: [T.PropertyValue]
  ) {
    var dict: [String: Any] = [:]
    values.forEach {
      let pair = $0.propertyValuePair
      dict[pair.name] = pair.value
    }

    self.realm.create(T.RealmObject.self, value: dict, update: .modified)
  }

  /// `RealmObject` 인스턴스를 받아 직접 `update`합니다.
  public func update<T>(
    _ value: T,
    update: Realm.UpdatePolicy = .modified
  ) where T: Object {
    self.realm.add(value, update: update)
  }

  /// `RealmObject` 인스턴스를 여러개 받아 직접 `update` 합니다.
  public func update<T>(
    _ values: [T],
    update: Realm.UpdatePolicy = .modified
  ) where T: Object {
    self.realm.add(values, update: update)
  }

  /// `RealmObject` 인스턴스를 받아 직접 `delete`합니다.
  public func delete<T>(
    _ value: T
  ) where T: Object {
    let objects = self.realm.objects(T.self).filter { $0 == value }
    self.realm.delete(objects)
  }
}
