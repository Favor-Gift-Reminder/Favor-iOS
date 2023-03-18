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
  /// 선물을 등록한 회원의 회원 번호
  @Persisted(originProperty: "giftList") var userNo: LinkingObjects<User>
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
  /// 선물과 관련된 친구 번호
  @Persisted var friendNo: Int
  /// 선물과 관련된 친구의 유저  번호
  @Persisted var friendUserNo: Int
  /// 받은 선물 / 준 선물 여부 (받은 선물 = `true`)
  @Persisted var isGiven: Bool
}
