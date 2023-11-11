//
//  ReminderObject.swift
//  Favor
//
//  Created by 이창준 on 2023/03/19.
//

import Foundation

import RealmSwift

public class ReminderObject: Object {

  // MARK: - Properties
  
  /// 리마인더  번호
  @Persisted(primaryKey: true) public var reminderNo: Int
  /// 리마인더 보유 회원 번호
  /// - Description: `User`의 `reminderList` 프로퍼티에 등록된 `Reminder` 테이블의 Primary Key.
  @Persisted(originProperty: "reminderList") public var userNo: LinkingObjects<UserObject>
  /// 리마인더 제목
  @Persisted public var title: String
  /// 리마인더로 등록한 이벤트의 날짜
  @Persisted public var date: Date
  /// 리마인더 메모
  @Persisted public var memo: String?
  /// 리마인더 알림 여부
  @Persisted public var shouldNotify: Bool
  /// 리마인더 알림 시간
  @Persisted public var notifyTime: Date
  /// 관련 친구의 회원 번호
  @Persisted public var friend: FriendObject?
  
  public override class func propertiesMapping() -> [String: String] {
    [
      "date": "reminderDate",
      "memo": "reminderMemo",
      "shouldNotify": "isAlarmSet",
      "notifyTime": "alarmTime",
      "relatedFriend": "friend"
    ]
  }

  // MARK: - Initializer

  /// - Parameters:
  ///   - reminderNo: ***PK*** 리마인더 번호
  ///   - title: 리마인더 제목
  ///   - date: 리마인더로 등록한 이벤트의 날짜
  ///   - memo: *`Optional`* 리마인더 메모
  ///   - isAlarmSet: 리마인더 알림 여부
  ///   - alarmTime: *`Optional`* 리마인더 알림 시간
  ///   - friend: 관련된 친구
  public convenience init(
    reminderNo: Int,
    title: String,
    date: Date,
    memo: String? = nil,
    shouldNotify: Bool,
    notifyTime: Date,
    friend: FriendObject?
  ) {
    self.init()
    self.reminderNo = reminderNo
    self.title = title
    self.date = date
    self.memo = memo
    self.shouldNotify = shouldNotify
    self.notifyTime = notifyTime
    self.friend = friend
  }
}
