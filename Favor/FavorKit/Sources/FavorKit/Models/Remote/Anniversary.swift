//
//  Anniversary.swift
//  Favor
//
//  Created by 이창준 on 2023/04/24.
//

import Foundation

import RealmSwift

public final class Anniversary: Object {

  // MARK: - Properties

  /// 기념일 번호
  @Persisted(primaryKey: true) public var anniversaryNo: Int
  /// 기념일 이름
  @Persisted public var title: String
  /// 기념일 날짜
  @Persisted public var date: Date
  /// 마이페이지 기념일 고정 여부
  @Persisted public var isPinned: Bool
  /// 기념일을 등록한 회원의 회원 번호
  @Persisted(originProperty: "anniversaryList") public var userNo: LinkingObjects<User>

  public override class func propertiesMapping() -> [String: String] {
    [
      "title": "anniversaryTitle",
      "date": "anniversaryDate"
    ]
  }

  // MARK: - Initializer

  /// - Parameters:
  ///   - anniversaryNo: ***PK*** 기념일 번호
  ///   - title: 기념일 이름
  ///   - date: 기념일 날짜
  ///   - isPinned: 마이페이지의 기념일 고정 여부
  public convenience init(
    anniversaryNo: Int,
    title: String,
    date: Date,
    isPinned: Bool
  ) {
    self.init()
    self.anniversaryNo = anniversaryNo
    self.title = title
    self.date = date
    self.isPinned = isPinned
  }
}
