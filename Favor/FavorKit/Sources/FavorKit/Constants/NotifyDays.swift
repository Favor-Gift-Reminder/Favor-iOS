//
//  NotifyDays.swift
//  Favor
//
//  Created by 이창준 on 2023/04/03.
//

import Foundation

public enum NotifyDays: CaseIterable {
  case day
  case dayBefore
  case twoDaysBefore
  case weekBefore
  case twoWeeksBefore
  case monthBefore

  public var stringValue: String {
    switch self {
    case .day: return "당일"
    case .dayBefore: return "하루 전"
    case .twoDaysBefore: return "이틀 전"
    case .weekBefore: return "일주일 전"
    case .twoWeeksBefore: return "2주일 전"
    case .monthBefore: return "한 달 전"
    }
  }
  
  /// `ReminderRequestDTO`를 위한
  /// 리마인더의 기념일 날짜와 사용자가 설정한 `NotifyDays`의 날짜의 차이를
  /// `String`으로 반환하는 메서드입니다.
  /// - Parameters:
  ///  - date: 리마인더의 기념일 날짜 입니다.
  public func toAlarmDate(_ date: Date?) -> String {
    guard let date else { return "" }
    let calendar = Calendar.current
    var dateComponents = DateComponents()
    
    switch self {
    case .day:
      dateComponents.day = 0
    case .dayBefore:
      dateComponents.day = -1
    case .twoDaysBefore:
      dateComponents.day = -2
    case .weekBefore:
      dateComponents.day = -7
    case .twoWeeksBefore:
      dateComponents.day = -14
    case .monthBefore:
      dateComponents.month = -1
    }    
    let resultDate = calendar.date(byAdding: dateComponents, to: date) ?? Date()
    return resultDate.toDTODateString()
  }
}
