//
//  FriendObject.swift
//  Favor
//
//  Created by 이창준 on 2023/03/19.
//

import RealmSwift

public class FriendObject: Object {
  
  // MARK: - Properties
  
  /// 친구 번호
  @Persisted(primaryKey: true) public var friendNo: Int
  /// 친구를 보유한 회원의 회원 번호
  @Persisted(originProperty: "friendList") public var userNo: LinkingObjects<UserObject>
  /// 친구 이름
  @Persisted public var friendName: String
  /// 친구 아이디
  @Persisted public var friendID: String
  /// 친구 사진
  @Persisted public var profilePhoto: PhotoObject?
  /// 친구 백그라운드 사진
  @Persisted public var backgroundPhoto: PhotoObject?
  /// 친구에 대한 메모
  @Persisted public var memo: String
  /// 친구가 회원일 경우, 해당 친구의 회원 번호
  @Persisted public var friendUserNo: Int?
  /// 친구의 기념일 목록
  @Persisted public var anniversaryList: List<AnniversaryObject>
  /// 친구의 취향 태그
  @Persisted public var favorList: MutableSet<String>
  /// 친구의 총 선물 갯수
  @Persisted public var totalGift: Int
  /// 친구의 받은 선물 갯수
  @Persisted public var receivedGift: Int
  /// 친구의 준 선물 갯수
  @Persisted public var givenGift: Int

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
  ///   - totalGift: 총 선물 갯수
  ///   - receivedGift: 받은 선물 갯수
  ///   - givenGift: 준 선물 갯수
  public convenience init(
    friendNo: Int,
    friendName: String,
    friendID: String,
    anniversaryList: [AnniversaryObject] = [],
    favorList: [String] = [],
    profilePhoto: PhotoObject? = nil,
    backgroundPhoto: PhotoObject? = nil,
    memo: String,
    friendUserNo: Int? = nil,
    totalGift: Int,
    receivedGift: Int,
    givenGift: Int
  ) {
    self.init()
    self.friendNo = friendNo
    self.friendUserNo = friendUserNo
    self.friendName = friendName
    self.friendID = friendID
    self.profilePhoto = profilePhoto
    self.backgroundPhoto = backgroundPhoto
    self.memo = memo
    self.favorList.insert(objectsIn: favorList)
    let newAnniversaryList = List<AnniversaryObject>()
    newAnniversaryList.append(objectsIn: anniversaryList)
    self.anniversaryList = newAnniversaryList
    self.totalGift = totalGift
    self.receivedGift = receivedGift
    self.givenGift = givenGift
  }  
}
