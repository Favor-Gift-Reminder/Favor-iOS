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
  @Persisted(primaryKey: true) public var friendNo: Int
  /// 친구를 보유한 회원의 회원 번호
  @Persisted(originProperty: "friendList") public var userNo: LinkingObjects<User>
  /// 친구 이름
  @Persisted public var name: String
  /// 친구 사진
  @Persisted public var profilePhoto: Photo?
  /// 친구에 대한 메모
  @Persisted public var memo: String?
  /// 친구가 회원일 경우, 해당 친구의 회원 번호
  @Persisted public var friendUserNo: Int?
  /// 친구의 회원 여부 (회원 = `true`)
  @Persisted public var isUser: Bool
  /// 친구의 기념일 목록
  @Persisted public var anniversaryList: List<Anniversary>
  /// 친구의 취향 태그
  @Persisted public var favorList: MutableSet<String>

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
    anniversaryList: [Anniversary] = [],
    favorList: [String] = [],
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
    self.favorList.insert(objectsIn: favorList)
    let newAnniversaryList = List<Anniversary>()
    newAnniversaryList.append(objectsIn: anniversaryList)
    self.anniversaryList = newAnniversaryList
  }
}
