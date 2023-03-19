//
//  Reminder.swift
//  Favor
//
//  Created by 이창준 on 2023/03/19.
//

import Foundation

import RealmSwift

public class Reminder: Object {

  // MARK: - Properties

  /// 리마인더  번호
  @Persisted(primaryKey: true) var reminderNo: Int
  /// 리마인더 제목
  @Persisted var title: String
  /// 리마인더로 등록한 이벤트의 날짜
  @Persisted var reminderDate: Date
  /// 리마인더 메모
  @Persisted var reminderMemo: String?
  /// 리마인더 알림 여부
  @Persisted var isAlarmSet: Bool
  /// 리마인더 알림 시간
  @Persisted var alarmTime: Date?
  /// 리마인더 보유 회원 번호
  @Persisted(originProperty: "reminderList") var userNo: LinkingObjects<User>
  /// 관련 친구의 회원 번호
  @Persisted var friendNo: Int

  // MARK: - Initializer

  /// - Parameters:
  ///   - reminderNo: ***PK*** 리마인더 번호
  ///   - title: 리마인더 제목
  ///   - date: 리마인더로 등록한 이벤트의 날짜
  ///   - memo: *`Optional`* 리마인더 메모
  ///   - isAlarmSet: 리마인더 알림 여부
  ///   - alarmTime: *`Optional`* 리마인더 알림 시간
  ///   - friendNo: 관련된 친구의 회원 번호
  public convenience init(
    reminderNo: Int,
    title: String,
    date: Date,
    memo: String? = nil,
    isAlarmSet: Bool,
    alarmTime: Date? = nil,
    friendNo: Int
  ) {
    self.init()
    self.reminderNo = reminderNo
    self.title = title
    self.reminderDate = date
    self.reminderMemo = memo
    self.isAlarmSet = isAlarmSet
    self.alarmTime = alarmTime
    self.friendNo = friendNo
  }
}
