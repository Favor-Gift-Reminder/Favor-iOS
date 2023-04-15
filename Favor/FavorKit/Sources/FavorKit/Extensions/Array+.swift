//
//  Array+.swift
//  Favor
//
//  Created by 이창준 on 2023/04/04.
//

import Foundation

// swiftlint:disable syntactic_sugar
extension ArraySlice {
  public func wrap() -> Array<Element> {
    return Array<Element>(self)
  }
}
// swiftlint:enable syntactic_sugar
