//
//  User.swift
//  Favor
//
//  Created by 이창준 on 2023/03/19.
//

import RealmSwift

class User: Object {
  /// 유저 번호
  @Persisted(primaryKey: true) var userNo: Int
  /// 회원 이메일 (로그인 시 사용)
  @Persisted var email: String
  /// 회원 아이디 (@)
  @Persisted var userID: String
  /// 회원 이름
  @Persisted var name: String
  /// 회원 취향 태그
  @Persisted var favorList: List<Int>
  /// 선물 목록
  @Persisted var giftList: List<Gift>
  /// 리마인더 목록
  @Persisted var reminderList: List<Reminder>
  /// 회원 친구 목록
  @Persisted var friendList: List<Friend>
  /// 회원 사진
  @Persisted var userPhoto: Photo?
  /// 회원 배경사진
  @Persisted var backgroundPhoto: Photo?

  override class func propertiesMapping() -> [String: String] {
    [
      "userID": "userId"
    ]
  }
}
