//
//  Encodable+.swift
//  Favor
//
//  Created by 이창준 on 2023/03/01.
//

import Foundation

extension Encodable {
  func toDictionary() -> [String: Any] {
    do {
      let data = try JSONEncoder().encode(self)
      let dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
      return dict ?? [:]
    } catch {
      return [:]
    }
  }
}
