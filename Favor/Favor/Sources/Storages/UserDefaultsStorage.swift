//
//  UserDefaultsStorage.swift
//  Favor
//
//  Created by 이창준 on 2023/03/08.
//

import Foundation

@propertyWrapper
struct UserDefault<T> {
  private let key: UserDefaultsKey
  private let defaultValue: T

  init(key: UserDefaultsKey, defaultValue: T) {
    self.key = key
    self.defaultValue = defaultValue
  }

  var wrappedValue: T {
    get {
      return UserDefaults.standard.object(forKey: key.rawValue) as? T ?? defaultValue
    }
    set {
      UserDefaults.standard.set(newValue, forKey: key.rawValue)
    }
  }
}
