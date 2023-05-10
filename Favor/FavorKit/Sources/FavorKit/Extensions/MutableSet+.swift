//
//  MutableSet+.swift
//  Favor
//
//  Created by 이창준 on 2023/04/22.
//

import RealmSwift

extension MutableSet {
  public func toArray() -> [Element] {
    return Array(self)
  }
}
