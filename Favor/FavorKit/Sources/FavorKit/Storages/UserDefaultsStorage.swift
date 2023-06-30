//
//  UserDefaultsStorage.swift
//  Favor
//
//  Created by 이창준 on 2023/03/08.
//

import Foundation

@propertyWrapper
public struct UserDefault<T: Codable> {
  private let key: UserDefaultsKey
  private let defaultValue: T

  init(key: UserDefaultsKey, defaultValue: T) {
    self.key = key
    self.defaultValue = defaultValue
  }

  public var wrappedValue: T {
    get {
      if let storedData = UserDefaults.standard.object(forKey: self.key.rawValue) as? Data {
        let decoder = JSONDecoder()
        if let loadedObject = try? decoder.decode(T.self, from: storedData) {
          return loadedObject
        }
      }
      return self.defaultValue
    }
    set {
      let encoder = JSONEncoder()
      if let encodedData = try? encoder.encode(newValue) {
        UserDefaults.standard.setValue(encodedData, forKey: self.key.rawValue)
      }
    }
  }
}
