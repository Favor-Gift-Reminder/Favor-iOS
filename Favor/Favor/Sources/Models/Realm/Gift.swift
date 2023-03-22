//
//  Gift.swift
//  Favor
//
//  Created by 이창준 on 2023/03/19.
//

import Foundation

import RealmSwift

public class Gift: Object {

  // MARK: - Properties

  /// 선물 번호 - **PK**
  @Persisted(primaryKey: true) var giftNo: Int
  /// 선물을 등록한 회원의 회원 번호
  /// - Description: `User`의 `giftList` 프로퍼티에 등록된 `Gift` 테이블의 Primary Key.
  @Persisted(originProperty: "giftList") var userNo: LinkingObjects<User>
  /// 선물 제목
  @Persisted var name: String
  /// 선물 날짜
  @Persisted var date: Date?
  /// 선물 사진 목록
  @Persisted var photoList: List<Photo>
  /// 선물 메모
  @Persisted var memo: String?
  /// 선물 카테고리
  @Persisted var category: Int?
  /// 선물 감정 기록
  @Persisted var emotion: Int?
  /// 선물 핀 여부
  @Persisted var isPinned: Bool
  /// 선물과 관련된 친구 번호
  @Persisted var relatedFriend: Friend?
  /// 받은 선물 / 준 선물 여부 (받은 선물 = `true`)
  @Persisted var isGiven: Bool

  public override class func propertiesMapping() -> [String: String] {
    [
      "name": "giftName",
      "date": "giftDate",
      "memo": "giftMemo"
    ]
  }

  // MARK: - Initializer

  /// - Parameters:
  ///   - giftNo: ***PK*** 선물 번호
  ///   - name: 선물 이름
  ///   - date: *`Optional`* 선물 전달 날짜
  ///   - memo: *`Optional`* 선물 메모
  ///   - category: *`Optional`* 선물 카테고리
  ///   - emotion: *`Optional`* 선물에 등록된 감정 기록
  ///   - isPinned: 선물 목록 혹은 타임라인에서의 핀 여부
  ///   - relatedFriend: *`Optional`* 선물과 관련된 친구의 번호
  ///   - isGiven: 받은 선물 / 준 선물 여부 (`true`: 받은 선물)
  public convenience init(
    _ giftNo: Int,
    name: String,
    date: Date? = nil,
    memo: String? = nil,
    category: Int? = nil, // enum화?
    emotion: Int? = nil, // enum화?
    isPinned: Bool = false,
    relatedFriend: Friend?,
    isGiven: Bool = false
  ) {
    self.init()
    self.giftNo = giftNo
    self.name = name
    self.date = date
    self.memo = memo
    self.category = category
    self.emotion = emotion
    self.isPinned = isPinned
    self.relatedFriend = relatedFriend
    self.isGiven = isGiven
  }
}
