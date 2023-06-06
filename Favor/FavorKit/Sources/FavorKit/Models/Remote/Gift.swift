//
//  Gift.swift
//  Favor
//
//  Created by 이창준 on 2023/03/19.
//

import Foundation

import RealmSwift

public class Gift: Object {

  // MARK: - Properties

  /// 선물 번호 - **PK**
  @Persisted(primaryKey: true) public var giftNo: Int
  /// 선물을 등록한 회원의 회원 번호
  /// - Description: `User`의 `giftList` 프로퍼티에 등록된 `Gift` 테이블의 Primary Key.
  @Persisted(originProperty: "giftList") public var userNo: LinkingObjects<User>
  /// 선물 제목
  @Persisted public var name: String
  /// 선물 날짜
  @Persisted public var date: Date?
  /// 선물 사진 목록
  @Persisted public var photoList: List<Photo>
  /// 선물 메모
  @Persisted public var memo: String?
  /// 선물 카테고리
  @Persisted public var privateCategory: String
  /// 선물 감정 기록
  @Persisted public var emotion: String?
  /// 선물 핀 여부
  @Persisted public var isPinned: Bool
  /// 선물과 관련된 친구 번호
  @Persisted public var friendList: List<Friend>
  /// 받은 선물 / 준 선물 여부 (받은 선물 = `true`)
  @Persisted public var isGiven: Bool

  public var category: FavorCategory {
    get { FavorCategory(rawValue: self.privateCategory) ?? .lightGift }
    set { self.privateCategory = newValue.rawValue }
  }

  public override class func propertiesMapping() -> [String: String] {
    [
      "name": "giftName",
      "date": "giftDate",
      "memo": "giftMemo",
      "privateCategory": "category"
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
    category: FavorCategory,
    emotion: String? = nil, // enum화?
    isPinned: Bool = false,
    friendList: [Friend] = [],
    isGiven: Bool = false
  ) {
    self.init()
    self.giftNo = giftNo
    self.name = name
    self.date = date
    self.memo = memo
    self.privateCategory = category.rawValue
    self.emotion = emotion
    self.isPinned = isPinned
    let newFriendList = List<Friend>()
    newFriendList.append(objectsIn: friendList)
    self.friendList = newFriendList
    self.isGiven = isGiven
  }

  // MARK: - Sort

  public enum SortType {
    case isPinned
    case isGiven
  }
}

// MARK: - Array Extension

extension Array where Element: Gift {
  public func sort(by type: Gift.SortType) -> (positive: Self, negative: Self) {
    switch type {
    case .isPinned:
      return self.sortByIsPinned()
    case .isGiven:
      return self.sortByIsGiven()
    }
  }

  private func sortByIsPinned() -> (positive: Self, negative: Self) {
    let pinnedGifts = self.filter { $0.isPinned }
    let unpinnedGifts = self.filter { !$0.isPinned }
    return (pinnedGifts, unpinnedGifts)
  }

  private func sortByIsGiven() -> (positive: Self, negative: Self) {
    let givenGifts = self.filter { $0.isGiven }
    let receivedGifts = self.filter { !$0.isGiven }
    return (givenGifts, receivedGifts)
  }

  public func filter(by filterType: GiftFilterType) -> Self {
    switch filterType {
    case .all:
      return self
    case .given:
      let (givenGifts, _) = self.sortByIsGiven()
      return givenGifts
    case .received:
      let (_, receivedGifts) = self.sortByIsGiven()
      return receivedGifts
    }
  }
}
