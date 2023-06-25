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
}


