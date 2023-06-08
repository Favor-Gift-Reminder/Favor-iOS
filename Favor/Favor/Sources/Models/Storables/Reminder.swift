//
//  Reminder.swift
//  Favor
//
//  Created by 이창준 on 2023/06/06.
//

import Foundation

import FavorKit
import FavorNetworkKit
import class RealmSwift.ThreadSafe

public struct Reminder: Storable, Receivable {

  // MARK: - Properties

  public let identifier: Int
  public var name: String
  public var date: Date
  public var memo: String?
  public var shouldNotify: Bool
  public var notifyDate: Date?
  public var relatedFriend: Int

  // MARK: - Storable

  public init(realmObject: ReminderObject) {
    @ThreadSafe var rlmObjectRef = realmObject
    guard let realmObject = rlmObjectRef else { fatalError() }
    
    self.identifier = realmObject.reminderNo
    self.name = realmObject.title
    self.date = realmObject.date
    self.memo = realmObject.memo
    self.shouldNotify = realmObject.shouldNotify
    self.notifyDate = realmObject.notifyTime
    self.relatedFriend = realmObject.friendNo
  }

  public func realmObject() -> ReminderObject {
    ReminderObject(
      reminderNo: self.identifier,
      title: self.name,
      date: self.date,
      memo: self.memo,
      shouldNotify: self.shouldNotify,
      notifyTime: self.notifyDate,
      friendNo: self.relatedFriend
    )
  }

  // MARK: - Receivable

  public init(dto: ReminderResponseDTO) {
    self.identifier = dto.reminderNo
    self.name = dto.reminderTitle
    self.date = dto.reminderDate
    self.memo = dto.memo
    self.shouldNotify = dto.isAlarmSet
    self.notifyDate = dto.alarmTime
    self.relatedFriend = dto.friendNo
  }

  // MARK: - Mock

  /// 비어있는 구조체를 생성합니다.
  ///
  /// > **⚠️ Warning** :
  ///   `identifier` 값을 -1로 줍니다. 값을 임시로 담을 때만 사용해주세요.
  public init() {
    self.identifier = -1
    self.name = ""
    self.date = .distantPast
    self.shouldNotify = false
    self.relatedFriend = -1
  }
}

// MARK: - PropertyValue

extension Reminder {
  public enum PropertyValue: PropertyValueType {
    case identifier(Int)
    case name(String)
    case date(Date)
    case memo(String?)
    case shouldNotify(Bool)
    case notifyDate(Date?)
    case relatedFriend(Int)

    public var propertyValuePair: PropertyValuePair {
      switch self {
      case .identifier(let identifier):
        return ("identifier", identifier)
      case .name(let name):
        return ("name", name)
      case .date(let date):
        return ("date", date)
      case .memo(let memo):
        return ("memo", memo ?? "")
      case .shouldNotify(let shouldNotify):
        return ("shouldNotify", shouldNotify)
      case .notifyDate(let notifyDate):
        return ("notifyDate", notifyDate ?? .now)
      case .relatedFriend(let relatedFriend):
        return ("relatedFriend", relatedFriend)
      }
    }
  }
}

// MARK: - Hashable

extension Reminder: Hashable, Equatable {
  public static func == (lhs: Reminder, rhs: Reminder) -> Bool {
    return lhs.identifier == rhs.identifier
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.identifier)
  }
}

// MARK: - Array Extension

extension Array where Element == Reminder {
  public func sort() -> (future: Self, past: Self) {
    let today = Calendar.current.startOfDay(for: .now)
    let (future, past) = self.reduce(into: (future: Self(), past: Self())) { result, reminder in
      let reminderDate = Calendar.current.startOfDay(for: reminder.date)
      if reminderDate >= today {
        result.future.append(reminder)
      } else {
        result.past.append(reminder)
      }
    }

    return (future: future, past: past)
  }
}
