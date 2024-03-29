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
  public var photos: [Photo]
  public var memo: String?
  public var category: FavorCategory
  public var emotion: FavorEmotion?
  public var isPinned: Bool
  public var relatedFriends: [Friend]
  public var tempFriends: [String]
  public var isGiven: Bool
  
  public var friends: [Friend] {
    self.relatedFriends + self.tempFriends.map { Friend(friendName: $0) }
  }
  
  // MARK: - Storable
  
  public init(realmObject: GiftObject) {
    @ThreadSafe var rlmObjectRef = realmObject
    guard let realmObject = rlmObjectRef else { fatalError() }
    
    self.identifier = realmObject.giftNo
    self.name = realmObject.name
    self.date = realmObject.date
    self.photos = realmObject.photoList.map { Photo(realmObject: $0) }
    self.memo = realmObject.memo
    self.category = realmObject.category
    self.emotion = realmObject.emotion
    self.isPinned = realmObject.isPinned
    self.relatedFriends = realmObject.friendList.compactMap(Friend.init(realmObject:))
    self.tempFriends = realmObject.tempFriendList.toArray()
    self.isGiven = realmObject.isGiven
  }
  
  public func realmObject() -> GiftObject {
    GiftObject(
      giftNo: self.identifier,
      name: self.name,
      date: self.date,
      memo: self.memo,
      photoList: self.photos.map { $0.realmObject() },
      category: self.category,
      emotion: self.emotion,
      isPinned: self.isPinned,
      friendList: self.relatedFriends.filter { $0.identifier > 0 }.compactMap { $0.realmObject() },
      tempFriendList: self.tempFriends,
      isGiven: self.isGiven
    )
  }
  
  // MARK: - Receivable
  
  public init(singleDTO: GiftSingleResponseDTO) {
    self.identifier = singleDTO.giftNo
    self.name = singleDTO.giftName
    self.date = singleDTO.giftDate
    self.photos = singleDTO.giftPhotoList.map { Photo(singleDTO: $0) }
    self.memo = singleDTO.giftMemo
    self.category = singleDTO.giftCategory
    self.emotion = singleDTO.emotion
    self.isPinned = singleDTO.isPinned
    self.relatedFriends = singleDTO.friendList.map { Friend(friendResponseDTO: $0) }
    self.tempFriends = singleDTO.tempFriendList
    self.isGiven = singleDTO.isGiven
  }
  
  public init(dto: GiftResponseDTO) {
    self.identifier = dto.giftNo
    self.name = dto.giftName
    self.date = dto.giftDate
    self.photos = dto.photoList.map { Photo(singleDTO: $0) }
    self.category = .etc
    self.emotion = .boring
    self.isPinned = dto.isPinned
    self.relatedFriends = []
    self.tempFriends = []
    self.isGiven = dto.isGiven
  }
  
  public func requestDTO() -> GiftRequestDTO {
    return GiftRequestDTO(
      giftName: self.name,
      giftDate: (self.date ?? .distantPast).toDTODateString(),
      giftMemo: self.memo ?? "",
      category: self.category,
      emotion: self.emotion ?? .good,
      isPinned: self.isPinned,
      isGiven: self.isGiven,
      friendNoList: self.relatedFriends.map { $0.identifier },
      tempFriendList: self.tempFriends
    )
  }
  
  public func updateRequestDTO() -> GiftUpdateRequestDTO {
    GiftUpdateRequestDTO(
      giftName: self.name,
      giftDate: (self.date ?? .distantPast).toDTODateString(),
      giftMemo: self.memo ?? "",
      category: self.category,
      emotion: self.emotion ?? .good,
      isGiven: self.isGiven,
      friendNoList: self.relatedFriends.filter { $0.identifier > 0 }.map { $0.identifier }
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
    self.category = .lightGift
    self.emotion = .touching
    self.isPinned = false
    self.relatedFriends = []
    self.tempFriends = []
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
    case photos([String])
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

extension Gift: Hashable {}

// MARK: - Image Cache

extension FavorKit.CacheKeyMapper {
  public enum GiftSubpath {
    
    case image(String)
    
    public var rawValue: String {
      switch self {
      case .image:
        return "image"
      }
    }
    
    public var url: String {
      switch self {
      case .image(let url):
        return url
      }
    }
  }
  
  public init(gift: Gift, subpath: GiftSubpath) {
    let key: String = "gift/\(gift.identifier)/\(subpath.rawValue)/\(subpath.url)"
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
