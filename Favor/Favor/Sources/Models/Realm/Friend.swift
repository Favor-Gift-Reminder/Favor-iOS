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
  @Persisted var name: String
  /// 친구 사진
  @Persisted var profilePhoto: Photo?
  /// 친구에 대한 메모
  @Persisted var memo: String?
  /// 친구가 회원일 경우, 해당 친구의 회원 번호
  @Persisted var friendUserNo: Int?
  /// 친구의 회원 여부 (회원 = `true`)
  @Persisted var isUser: Bool

  public override class func propertiesMapping() -> [String: String] {
    [
      "name": "friendName",
      "profilePhoto": "friendPhoto",
      "memo": "friendMemo"
    ]
  }

  // MARK: - Initializer

  /// - Parameters:
  ///   - friendNo: ***PK*** 친구 번호
  ///   - name: 친구 이름
  ///   - profilePhoto: 친구 사진
  ///   - memo: 친구에 대한 메모
  ///   - friendUserNo: 친구가 회원일 경우, 해당 친구의 회원 번호
  ///   - isUser: 친구의 회원 여부 (true: 회원)
  public convenience init(
    friendNo: Int,
    name: String,
    profilePhoto: Photo? = nil,
    memo: String? = nil,
    friendUserNo: Int? = nil,
    isUser: Bool
  ) {
    self.init()
    self.friendNo = friendNo
    self.name = name
    self.profilePhoto = profilePhoto
    self.memo = memo
    self.friendUserNo = friendUserNo
    self.isUser = isUser
  }
}
