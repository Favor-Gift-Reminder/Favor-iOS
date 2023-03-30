//
//  DateComponents+.swift
//  Favor
//
//  Created by 이창준 on 2023/03/29.
//

import Foundation

extension DateComponents {
  /// yyyy년 M월의 형식의 String 값으로 변환하여 반환합니다.
  public func toYearMonthString() -> String? {
    guard
      let year = self.year,
      let month = self.month
    else { return nil }
    return "\(year)년 \(month)월"
  }
}

extension DateComponents: Comparable {
  public static func < (lhs: DateComponents, rhs: DateComponents) -> Bool {
    if lhs.year != rhs.year {
      return lhs.year ?? 0 < rhs.year ?? 0
    }
    if lhs.month != rhs.month {
      return lhs.month ?? 0 < rhs.month ?? 0
    }
    if lhs.day != rhs.day {
      return lhs.day ?? 0 < rhs.day ?? 0
    }
    if lhs.hour != rhs.hour {
      return lhs.hour ?? 0 < rhs.hour ?? 0
    }
    if lhs.minute != rhs.minute {
      return lhs.minute ?? 0 < rhs.minute ?? 0
    }
    if lhs.second != rhs.second {
      return lhs.second ?? 0 < rhs.second ?? 0
    }
    return false
  }
}
