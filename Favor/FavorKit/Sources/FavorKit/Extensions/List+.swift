//
//  List+.swift
//  Favor
//
//  Created by 이창준 on 2023/04/22.
//

import RealmSwift

extension List {
  public func toArray() -> [Element] {
    return Array(self)
  }
}
