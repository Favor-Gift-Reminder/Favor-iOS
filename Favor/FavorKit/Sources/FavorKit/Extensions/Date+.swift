//
//  Date+.swift
//  Favor
//
//  Created by 이창준 on 2023/03/29.
//

import Foundation

extension Date {
  public func toYearString() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy"
    return formatter.string(from: self)
  }

  public func toMonthString() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "M"
    return formatter.string(from: self)
  }
}
