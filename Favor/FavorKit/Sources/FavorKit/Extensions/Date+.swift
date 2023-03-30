//
//  Date+.swift
//  Favor
//
//  Created by 이창준 on 2023/03/29.
//

import Foundation

extension Date {
  public var currentYear: Int {
    Int(self.toYearString()) ?? 0
  }

  public var currentMonth: Int {
    Int(self.toMonthString()) ?? 0
  }

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