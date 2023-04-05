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

  public func toDateString() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy년 M월 d일"
    return formatter.string(from: self)
  }

  public func toTimeString() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "a h시 m분"
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
    let dateComponents = Calendar.current.dateComponents([.day], from: self, to: Date())
    guard let days = dateComponents.day else { return "D-Day 계산 실패" }
    let dayDate = self.toDayString()
    switch days.signum() {
    case 0: return "오늘"
    case ..<0: return "\(dayDate)일까지 D\(days)"
    case 1...: return "\(days)일 전"
    default: return "D-Day 계산 실패"
    }
  }
}
