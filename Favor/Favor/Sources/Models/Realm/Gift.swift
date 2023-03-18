//
//  Gift.swift
//  Favor
//
//  Created by 이창준 on 2023/03/19.
//

import Foundation

import RealmSwift

class Gift: Object {
  /// 선물 번호
  @Persisted(primaryKey: true) var giftNo: Int
  /// 회원 번호
  @Persisted var userNo: Int
  /// 선물 제목
  @Persisted var giftName: String
  /// 선물 날짜
  @Persisted var giftDate: Date?
  /// 선물 사진 목록
  @Persisted var photoList: List<Photo>
  /// 선물 메모
  @Persisted var giftMemo: String?
  /// 선물 카테고리
  @Persisted var category: Int?
  /// 선물 감정 기록
  @Persisted var emotion: Int?
  /// 선물 핀 여부
  @Persisted var isPinned: Bool
  /// 친구 번호
  @Persisted(originProperty: "friendNo") var friendNo: LinkingObjects<Friend>
  /// 친구 유저  번호
  @Persisted(originProperty: "userNo") var friendUserNo: LinkingObjects<User>
  /// 받은 선물 / 준 선물 여부 (받은 선물 = `true`)
  @Persisted var isGiven: Bool
}
