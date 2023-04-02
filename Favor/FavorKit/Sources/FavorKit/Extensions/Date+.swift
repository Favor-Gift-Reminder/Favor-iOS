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

  public func toString() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy년 M월 d일"
    return formatter.string(from: self)
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

  public func toDayString() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "d"
    return formatter.string(from: self)
  }

  public func toDday() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "d일까지 'D'-d"
    return formatter.string(from: self)
  }
}
