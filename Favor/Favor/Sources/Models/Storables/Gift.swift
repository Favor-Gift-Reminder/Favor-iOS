//
//  Gift.swift
//  Favor
//
//  Created by 이창준 on 2023/06/05.
//

import UIKit

import FavorKit
import FavorNetworkKit
import class RealmSwift.ThreadSafe

public struct Gift: Storable, Receivable {

  // MARK: - Properties

  public let identifier: Int
  public var name: String
  public var date: Date?
  public var photos: [UIImage]
  public var memo: String?
  public var category: FavorCategory
  public var emotion: FavorEmotion?
  public var isPinned: Bool
  public var relatedFriends: [Friend]
  public var isGiven: Bool

  // MARK: - Storable

  public init(realmObject: GiftObject) {
    @ThreadSafe var rlmObjectRef = realmObject
    guard let realmObject = rlmObjectRef else { fatalError() }
    
    self.identifier = realmObject.giftNo
    self.name = realmObject.name
    self.date = realmObject.date
//    self.photos = realmObject.photoList.toArray()
    self.photos = []
    self.memo = realmObject.memo
    self.category = realmObject.category
    self.emotion = realmObject.emotion
    self.isPinned = realmObject.isPinned
    self.relatedFriends = realmObject.friendList.compactMap(Friend.init(realmObject:))
    self.isGiven = realmObject.isGiven
  }

  public func realmObject() -> GiftObject {
    GiftObject(
      giftNo: self.identifier,
      name: self.name,
      date: self.date,
      memo: self.memo,
      category: self.category,
      emotion: self.emotion,
      isPinned: self.isPinned,
      friendList: self.relatedFriends.compactMap { $0.realmObject() },
      isGiven: self.isGiven
    )
  }

  // MARK: - Receivable

  public init(dto: GiftResponseDTO) {
    self.identifier = dto.giftNo
    self.name = dto.giftName
    self.date = dto.giftDate
    self.photos = []
    self.memo = dto.giftMemo
    self.category = dto.category
    self.emotion = dto.emotion
    self.isPinned = dto.isPinned
    self.relatedFriends = dto.friendList.compactMap(Friend.init(friendResponseDTO:)) 
    self.isGiven = dto.isGiven
  }

  public func requestDTO() -> GiftRequestDTO {
    GiftRequestDTO(
      giftName: self.name,
      giftDate: (self.date ?? .distantPast).toDTODateString(),
      giftMemo: self.memo ?? "",
      category: self.category,
      emotion: self.emotion ?? .good,
      isPinned: self.isPinned,
      isGiven: self.isGiven,
      friendNoList: self.relatedFriends.map { $0.identifier }
    )
  }

  public func updateRequestDTO() -> GiftUpdateRequestDTO {
    GiftUpdateRequestDTO(
      giftName: self.name,
      giftDate: (self.date ?? .distantPast).toDTODateString(),
      giftMemo: self.memo ?? "",
      category: self.category,
      emotion: self.emotion ?? .good,
      isPinned: self.isPinned,
      isGiven: self.isGiven,
      friendNoList: self.relatedFriends.map { $0.identifier }
    )
  }

  // MARK: - Mock

  /// 비어있는 구조체를 생성합니다.
  ///
  /// > **⚠️ Warning** :
  ///   `identifier` 값을 -1로 줍니다. 값을 임시로 담을 때만 사용해주세요.
  public init() {
    self.identifier = -1
    self.name = ""
    self.photos = []
    self.category = .etc
    self.emotion = .xoxo
    self.isPinned = false
    self.relatedFriends = []
    self.isGiven = false
  }

  // MARK: - Sort

  public enum SortType {
    case isPinned
    case isGiven
  }
}

// MARK: - PropertyValue

extension Gift {
  public enum PropertyValue: PropertyValueType {
    case identifier(Int)
    case name(String)
    case date(Date?)
    case photos([UIImage])
    case memo(String?)
    case category(FavorCategory)
    case emotion(String)
    case isPinned(Bool)
    case relatedFriends([Friend])
    case isGiven(Bool)

    public var propertyValuePair: PropertyValuePair {
      switch self {
      case .identifier(let identifier):
        return ("identifier", identifier)
      case .name(let name):
        return ("name", name)
      case .date(let date):
        return ("date", date ?? .distantPast)
      case .photos(let photos):
        return ("photos", photos)
      case .memo(let memo):
        return ("memo", memo ?? "")
      case .category(let category):
        return ("category", category)
      case .emotion(let emotion):
        return ("emotion", emotion)
      case .isPinned(let isPinned):
        return ("isPinned", isPinned)
      case .relatedFriends(let relatedFriends):
        return ("relatedFriends", relatedFriends)
      case .isGiven(let isGiven):
        return ("isGiven", isGiven)
      }
    }
  }
}

// MARK: - Hashable

extension Gift: Hashable {
  public static func == (lhs: Gift, rhs: Gift) -> Bool {
    return lhs.identifier == rhs.identifier
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.identifier)
  }
}

// MARK: - Image Cache

extension FavorKit.CacheKeyMapper {
  public enum GiftSubpath {
    
    case image(Int)
    
    public var rawValue: String {
      switch self {
      case .image:
        return "image"
      }
    }
    
    public var index: Int {
      switch self {
      case .image(let index):
        return index
      }
    }
  }
  
  public init(gift: Gift, subpath: GiftSubpath) {
    // TODO: url 추가
    // "gift/\(gift.identifier)/\(subpath.rawValue)/\(subpath.index)/\(gift.photo.remote)"
    let key: String = "gift/\(gift.identifier)/\(subpath.rawValue)/\(subpath.index)"
    var mapper = CacheKeyMapper(key: key, cacheType: .disk)
    mapper.preferredSize = ImageCacheManager.Metric.bannerSize
    self = mapper
  }
}

// MARK: - Array Extension

extension Array where Element == Gift {
  public func sort(by type: Element.SortType) -> (positive: Self, negative: Self) {
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
