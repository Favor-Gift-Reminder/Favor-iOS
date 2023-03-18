//
//  Friend.swift
//  Favor
//
//  Created by 이창준 on 2023/03/19.
//

import RealmSwift

class Friend: Object {
  /// 친구 번호
  @Persisted(primaryKey: true) var friendNo: Int
  /// 친구를 보유한 회원의 회원 번호
  @Persisted(originProperty: "userNo") var userNo: LinkingObjects<User>
  /// 친구 이름
  @Persisted var friendName: String
  /// 친구 사진
  @Persisted var friendPhoto: Photo?
  /// 친구에 대한 메모
  @Persisted var friendMemo: String?
  /// 친구의 기념일 목록
  @Persisted var reminderList: List<Reminder>
  /// 친구와 관련된 선물 목록
  @Persisted var giftList: List<Gift>
  /// 친구가 회원일 경우, 해당 친구의 회원 번호
  @Persisted(originProperty: "userNo") var friendUserNo: LinkingObjects<User>
  /// 친구의 회원 여부 (회원 = `true`)
  @Persisted var isUser: Bool
}
