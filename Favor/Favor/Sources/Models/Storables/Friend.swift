//
//  Friend.swift
//  Favor
//
//  Created by 이창준 on 2023/06/06.
//

import UIKit

import FavorKit
import FavorNetworkKit
import class RealmSwift.ThreadSafe

public struct Friend: Storable, Receivable {
  
  // MARK: - Properties
  public let identifier: Int
  public var friendName: String
  public var friendID: String
  public var profilePhoto: Photo?
  public var backgroundPhoto: Photo?
  public var memo: String
  public var anniversaryList: [Anniversary]
  public var favorList: [Favor]
  public let totalGift: Int
  public let receivedGift: Int
  public let givenGift: Int
  
  // MARK: - Storable
  
  public init(realmObject: FriendObject) {
    @ThreadSafe var rlmObjectRef = realmObject
    guard let realmObject = rlmObjectRef else { fatalError() }
    
    self.identifier = realmObject.friendNo
    self.friendName = realmObject.friendName
    self.friendID = realmObject.friendID
    if let photoObject = realmObject.profilePhoto {
      self.profilePhoto = Photo(realmObject: photoObject)
    }
    if let backgroundObject = realmObject.backgroundPhoto {
      self.backgroundPhoto = Photo(realmObject: backgroundObject)
    }
    self.memo = realmObject.memo
    self.anniversaryList = realmObject.anniversaryList.compactMap(Anniversary.init(realmObject:))
    self.favorList = realmObject.favorList.compactMap(Favor.init(rawValue:))
    self.totalGift = realmObject.totalGift
    self.receivedGift = realmObject.receivedGift
    self.givenGift = realmObject.givenGift
  }
  
  public func realmObject() -> FriendObject {
    FriendObject(
      friendNo: self.identifier,
      friendName: self.friendName,
      friendID: self.friendID,
      anniversaryList: self.anniversaryList.compactMap { $0.realmObject() },
      favorList: self.favorList.compactMap { $0.rawValue },
      profilePhoto: self.profilePhoto?.realmObject(),
      backgroundPhoto: self.backgroundPhoto?.realmObject(),
      memo: self.memo,
      totalGift: self.totalGift,
      receivedGift: self.receivedGift,
      givenGift: self.givenGift
    )
  }
  
  // MARK: - Receivable
  
  public init(friendResponseDTO: FriendResponseDTO) {
    self.identifier = friendResponseDTO.friendNo
    self.friendName = friendResponseDTO.friendName
    self.friendID = ""
    if let photoDTO = friendResponseDTO.photo {
      self.profilePhoto = Photo(singleDTO: photoDTO)
    }
    self.memo = ""
    self.anniversaryList = []
    self.favorList = []
    self.totalGift = -1
    self.receivedGift = -1
    self.givenGift = -1
  }
  
  public init(singleDTO: FriendSingleResponseDTO) {
    self.identifier = singleDTO.friendNo
    self.friendName = singleDTO.friendName
    self.memo = singleDTO.friendMemo
    self.anniversaryList = singleDTO.anniversaryList.map { Anniversary(singleDTO: $0) }
    self.favorList = singleDTO.favorList.compactMap { Favor(rawValue: $0) }
    self.totalGift = singleDTO.totalGift
    self.receivedGift = singleDTO.receivedGift
    self.givenGift = singleDTO.givenGift
    self.friendID = singleDTO.friendId
    if let userPhoto = singleDTO.userPhoto {
      self.profilePhoto = Photo(singleDTO: userPhoto)
    }
    if let backgroundPhoto = singleDTO.userBackgroundPhoto {
      self.backgroundPhoto = Photo(singleDTO: backgroundPhoto)
    }
  }
  
  // MARK: - Mock

  /// 비어있는 구조체를 생성합니다.
  ///
  /// > **⚠️ Warning** :
  ///   `identifier` 값을 -1로 줍니다. 값을 임시로 담을 때만 사용해주세요.
  public init() {
    self.identifier = -1
    self.friendName = ""
    self.friendID = ""
    self.anniversaryList = []
    self.favorList = []
    self.givenGift = 0
    self.totalGift = 0
    self.receivedGift = 0
    self.memo = ""
  }
  
  /// 비회원 친구 구조체를 생성합니다.
  /// 비회원 친구는 `identifier`가 `음수`를 갖습니다.
  public init(friendName: String) {
    self.identifier = -1
    self.friendName = friendName
    self.friendID = ""
    self.anniversaryList = []
    self.favorList = []
    self.givenGift = 0
    self.totalGift = 0 
    self.receivedGift = 0
    self.memo = ""
  }
}

// MARK: - PropertyValue

extension Friend {
  public enum PropertyValue: PropertyValueType {
    case identifier(Int)
    case name(String)
    case profilePhoto(UIImage?)
    case memo(String?)
    case isUser(Bool)
    case userIdentifier(Int)
    case anniversaryList([Anniversary])
    case favorList([Favor])

    public var propertyValuePair: PropertyValuePair {
      switch self {
      case .identifier(let identifier):
        return ("identifier", identifier)
      case .name(let name):
        return ("name", name)
      case .profilePhoto(let profilePhoto):
        return ("profilePhoto", profilePhoto ?? .favorIcon(.friend)!)
      case .memo(let memo):
        return ("memo", memo ?? "")
      case .isUser(let isUser):
        return ("isUser", isUser)
      case .userIdentifier(let userIdentifier):
        return ("userIdentifier", userIdentifier)
      case .anniversaryList(let anniversaryList):
        return ("anniversaryList", anniversaryList)
      case .favorList(let favorList):
        return ("favorList", favorList)
      }
    }
  }
}

// MARK: - Hashable

extension Friend: Hashable {}

// MARK: - Image Cache

extension FavorKit.CacheKeyMapper {
  public enum FriendSubpath {
    case background(String)
    case profilePhoto(String)
    
    var rawValue: String {
      switch self {
      case .background:
        return "background"
      case .profilePhoto:
        return "profilePhoto"
      }
    }
    
    var remote: String {
      switch self {
      case .background(let url):
        return url
      case .profilePhoto(let url):
        return url
      }
    }
  }
  
  public init(friend: Friend, subpath: FriendSubpath) {
    let key: String = "friend/\(friend.identifier)/\(subpath.rawValue)/\(subpath.remote)"
    var mapper = CacheKeyMapper(key: key, cacheType: .memory)
    switch subpath {
    case .background:
      mapper.preferredSize = ImageCacheManager.Metric.bannerSize
    case .profilePhoto:
      mapper.preferredSize = ImageCacheManager.Metric.bannerSize
    }
    self = mapper
  }
}
