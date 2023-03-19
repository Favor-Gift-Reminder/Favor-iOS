//
//  Friend.swift
//  Favor
//
//  Created by 이창준 on 2023/03/19.
//

import RealmSwift

public class Friend: Object {

  // MARK: - Properties

  /// 친구 번호
  @Persisted(primaryKey: true) var friendNo: Int
  /// 친구를 보유한 회원의 회원 번호
  @Persisted(originProperty: "friendList") var userNo: LinkingObjects<User>
  /// 친구 이름
  @Persisted var friendName: String
  /// 친구 사진
  @Persisted var friendPhoto: Photo?
  /// 친구에 대한 메모
  @Persisted var friendMemo: String?
  /// 친구가 회원일 경우, 해당 친구의 회원 번호
  @Persisted var friendUserNo: Int?
  /// 친구의 회원 여부 (회원 = `true`)
  @Persisted var isUser: Bool

  // MARK: - Initializer

  /// - Parameters:
  ///   - friendNo: ***PK*** 친구 번호
  ///   - friendName: 친구 이름
  ///   - friendPhoto: 친구 사진
  ///   - friendMemo: 친구에 대한 메모
  ///   - friendUserNo: 친구가 회원일 경우, 해당 친구의 회원 번호
  ///   - isUser: 친구의 회원 여부 (true: 회원)
  public convenience init(
    friendNo: Int,
    friendName: String,
    friendPhoto: Photo? = nil,
    friendMemo: String? = nil,
    friendUserNo: Int? = nil,
    isUser: Bool
  ) {
    self.init()
    self.friendNo = friendNo
    self.friendName = friendName
    self.friendPhoto = friendPhoto
    self.friendMemo = friendMemo
    self.friendUserNo = friendUserNo
    self.isUser = isUser
  }
}
