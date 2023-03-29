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
