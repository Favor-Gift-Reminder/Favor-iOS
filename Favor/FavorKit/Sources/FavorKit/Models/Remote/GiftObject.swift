//
//  GiftObject.swift
//  Favor
//
//  Created by 이창준 on 2023/03/19.
//

import Foundation

import RealmSwift

public class GiftObject: Object {

  // MARK: - Properties

  /// 선물 번호 - **PK**
  @Persisted(primaryKey: true) public var giftNo: Int
  /// 선물 제목
  @Persisted public var name: String
  /// 선물 날짜
  @Persisted public var date: Date?
  /// 선물 사진 목록
  @Persisted public var photoList: List<PhotoObject>
  /// 선물 메모
  @Persisted public var memo: String?
  /// 선물 카테고리
  @Persisted private var privateCategory: String
  /// 선물 감정 기록
  @Persisted public var privateEmotion: String?
  /// 선물 핀 여부
  @Persisted public var isPinned: Bool
  /// 선물과 관련된 친구
  @Persisted public var friendList: List<FriendObject>
  /// 선물과 관련된 비회원 친구
  @Persisted public var tempFriendList: List<String>
  /// 받은 선물 / 준 선물 여부 (받은 선물 = `true`)
  @Persisted public var isGiven: Bool

  public var category: FavorCategory {
    get { FavorCategory(rawValue: self.privateCategory) ?? .lightGift }
    set { self.privateCategory = newValue.rawValue }
  }

  public var emotion: FavorEmotion? {
    get {
      guard let emotion = privateEmotion else { return nil }
      return FavorEmotion(rawValue: emotion)
    }
    set { self.privateEmotion = newValue?.rawValue }
  }
  
  public override class func propertiesMapping() -> [String: String] {
    [
      "name": "giftName",
      "date": "giftDate",
      "memo": "giftMemo",
      "privateCategory": "category",
      "privateEmotion": "emotion"
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
  ///   - friendList: 선물과 관련된 친구 리스트
  ///   - isGiven: 받은 선물 / 준 선물 여부 (`true`: 받은 선물)
  public convenience init(
    giftNo: Int,
    name: String,
    date: Date? = nil,
    memo: String? = nil,
    photoList: [PhotoObject] = [],
    category: FavorCategory,
    emotion: FavorEmotion? = nil,
    isPinned: Bool = false,
    friendList: [FriendObject] = [],
    tempFriendList: [String] = [],
    isGiven: Bool = false
  ) {
    self.init()
    self.giftNo = giftNo
    self.name = name
    self.date = date
    self.memo = memo
    let newPhotoList = List<PhotoObject>()
    newPhotoList.append(objectsIn: photoList)
    self.photoList = newPhotoList
    self.privateCategory = category.rawValue
    self.privateEmotion = emotion?.rawValue
    self.isPinned = isPinned
    let newFriendList = List<FriendObject>()
    newFriendList.append(objectsIn: friendList)
    self.friendList = newFriendList
    let newTempFriendList = List<String>()
    newTempFriendList.append(objectsIn: tempFriendList)
    self.tempFriendList = newTempFriendList
    self.isGiven = isGiven
  }
}
