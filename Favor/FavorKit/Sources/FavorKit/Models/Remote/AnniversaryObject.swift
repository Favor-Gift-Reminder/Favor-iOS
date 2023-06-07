//
//  AnniversaryObject.swift
//  Favor
//
//  Created by 이창준 on 2023/04/24.
//

import Foundation

import RealmSwift

public final class AnniversaryObject: Object {

  // MARK: - Properties

  /// 기념일 번호
  @Persisted(primaryKey: true) public var anniversaryNo: Int
  /// 기념일 이름
  @Persisted public var title: String
  /// 기념일 카테고리
  @Persisted private var privateCategory: String
  /// 기념일 날짜
  @Persisted public var date: Date
  /// 마이페이지 기념일 고정 여부
  @Persisted public var isPinned: Bool
  /// 기념일을 등록한 회원의 회원 번호
  @Persisted(originProperty: "anniversaryList") public var userNo: LinkingObjects<UserObject>

  public var category: AnniversaryCategory {
    get { AnniversaryCategory(rawValue: self.privateCategory) ?? .congrat }
    set { self.privateCategory = newValue.rawValue }
  }

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

// MARK: - Array Extension

extension Array where Element: AnniversaryObject {

  /// 기념일 배열을 아래 규칙에 따라 정렬합니다.
  /// ```
  /// 다가오는 기념일
  /// · 가장 가까운 기념일
  /// · ~
  /// · 가장 먼 기념일
  /// 지난 기념일
  /// · 가장 최근에 지난 기념일
  /// · ~
  /// · 가장 오래 지난 기념일
  /// ```
  public func sort() -> Self {
    let today = Date().withoutTime()

    let upcomingAnniversaries = self
      .filter { anniversary in
        anniversary.date.withoutTime() >= today
      }
      .sorted { lhs, rhs in
        lhs.date < rhs.date
      }

    let expiredAnniversaries = self
      .filter { anniversary in
        anniversary.date.withoutTime() < today
      }
      .sorted { lhs, rhs in
        lhs.date > rhs.date
      }

    return upcomingAnniversaries + expiredAnniversaries
  }
}
