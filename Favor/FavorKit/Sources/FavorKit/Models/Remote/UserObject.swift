//
//  UserObject.swift
//  Favor
//
//  Created by 이창준 on 2023/03/19.
//

import RealmSwift

public class UserObject: Object {

  // MARK: - Properties

  /// 회원 번호
  @Persisted(primaryKey: true) public var userNo: Int
  /// 회원 이메일 (로그인 시 사용)
  @Persisted public var email: String
  /// 회원 아이디 (@)
  @Persisted public var userID: String
  /// 회원 이름
  @Persisted public var name: String
  /// 회원 취향 태그
  @Persisted public var favorList: MutableSet<String>
  /// 선물 목록
  @Persisted public var giftList: List<GiftObject>
  /// 리마인더 목록
  @Persisted public var reminderList: List<ReminderObject>
  /// 기념일 목록
  @Persisted public var anniversaryList: List<AnniversaryObject>
  /// 회원 친구 목록
  @Persisted public var friendList: List<FriendObject>
  /// 회원 사진
  @Persisted public var userPhoto: Photo?
  /// 회원 배경사진
  @Persisted public var backgroundPhoto: Photo?

  public override class func propertiesMapping() -> [String: String] {
    [
      "userID": "userId"
    ]
  }

  // MARK: - Initializer

  /// - Parameters:
  ///   - userNo: ***PK*** 회원 번호
  ///   - email: 로그인 시 사용되는 회원 이메일
  ///   - userID: 검색 시 사용되는 회원 아이디 - *ex: @favor_281*
  ///   - name: 회원 이름
  ///   - userPhoto: *`Optioinal`* 회원 프로필 사진
  ///   - backgroundPhoto: *`Optional`* 회원 프로필 배경 사진
  public convenience init(
    userNo: Int,
    email: String,
    userID: String,
    name: String,
    favorList: [String] = [], // enum화?
    giftList: [GiftObject] = [],
    anniversaryList: [AnniversaryObject] = [],
    friendList: [FriendObject] = [],
    userPhoto: Photo? = nil,
    backgroundPhoto: Photo? = nil
  ) {
    self.init()
    self.userNo = userNo
    self.email = email
    self.userID = userID
    self.name = name
    self.favorList.insert(objectsIn: favorList)
    let newGiftList = List<GiftObject>()
    newGiftList.append(objectsIn: giftList)
    self.giftList = newGiftList
    let newAnniversaryList = List<AnniversaryObject>()
    newAnniversaryList.append(objectsIn: anniversaryList)
    self.anniversaryList = newAnniversaryList
    let newFriendList = List<FriendObject>()
    newFriendList.append(objectsIn: friendList)
    self.friendList = newFriendList
    self.userPhoto = userPhoto
    self.backgroundPhoto = backgroundPhoto
  }
}
