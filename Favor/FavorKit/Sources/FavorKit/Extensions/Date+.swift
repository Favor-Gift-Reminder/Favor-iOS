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

  public func withoutTime() -> Self {
    let calendar = Calendar.current
    let dateCommponents = calendar.dateComponents([.year, .month, .day], from: self)
    guard let dateWithoutTime = calendar.date(from: dateCommponents) else { return self }
    return dateWithoutTime
  }

  public func toDateString() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy년 M월 d일"
    return formatter.string(from: self)
  }

  public func toShortenDateString() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy. M. d"
    return formatter.string(from: self)
  }

  public func toTimeString() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "a hh시 mm분"
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
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "d"
    return formatter.string(from: self)
  }

  public func toDday() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    let todayDate = dateFormatter.date(from: Date().toDTODateString() ) ?? Date()
    let dateComponents = Calendar.current.dateComponents([.day], from: self, to: todayDate)
    guard let days = dateComponents.day else { return "D-Day 계산 실패" }
    let dayDate = self.toDayString()
    switch days.signum() {
    case 0: return "오늘"
    case ..<0: return "\(dayDate)일까지 D\(days)"
    case 1...: return "\(days)일 전"
    default: return "D-Day 계산 실패"
    }
  }
  
  public func toDTODateString() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: self)
  }
  
  public func toDTOTimeString() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: self)
  }
  
  /// 리마인더 수정에서 필요한 날짜를
  /// `NotifyDays` 열거형으로 변환하는 메서드입니다.
  ///  - Parameters:
  ///   - reminderDate: 알람으로 설정했던 시간입니다.
  public func toNotifyDays(_ alarmDate: Date?) -> NotifyDays {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    let alarmDate = dateFormatter.date(from: alarmDate?.toDTODateString() ?? "")
    let calendar = Calendar.current
    
    // 리마인더의 기념일 날짜와 차이를 구합니다.
    let dateComponents = calendar.dateComponents([.day], from: self, to: alarmDate ?? Date())
    
    // 구한 날짜의 일(day) 값입니다.
    guard let dayComponent = dateComponents.day else { return .day }
    
    switch dayComponent {
    case 0: // 당일
      return .day
    case -1: // 하루 전
      return .dayBefore
    case -2: // 이틀 전
      return .twoDaysBefore
    case -7: // 일주일 전
      return .weekBefore
    case -14: // 이주일 전
      return .twoWeeksBefore
    default: // 한달 전
      return .monthBefore
    }
  }
}
