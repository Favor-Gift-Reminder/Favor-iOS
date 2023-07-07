//
//  User.swift
//  Favor
//
//  Created by 이창준 on 2023/06/05.
//

import UIKit

import FavorKit
import FavorNetworkKit
import class RealmSwift.ThreadSafe

public struct User: Storable, Receivable {

  // MARK: - Properties

  public let identifier: Int
  public var email: String
  public var searchID: String
  public var name: String
  public var favorList: [Favor]
  public var reminderList: [Reminder]
  public var anniversaryList: [Anniversary]
  public var friendList: [Friend]
  public var profilePhoto: UIImage?
  public var profileBackgroundPhoto: UIImage?
  public var givenGifts: Int
  public var receivedGifts: Int
  public var totalgifts: Int

  // MARK: - Storable

  public init(realmObject: UserObject) {
    @ThreadSafe var rlmObjectRef = realmObject
    guard let realmObject = rlmObjectRef else { fatalError() }
    
    self.identifier = realmObject.userNo
    self.email = realmObject.email
    self.searchID = realmObject.userID
    self.name = realmObject.name
    self.favorList = realmObject.favorList.toArray().compactMap { Favor(rawValue: $0) }
    self.reminderList = realmObject.reminderList.compactMap(Reminder.init(realmObject:))
    self.anniversaryList = realmObject.anniversaryList.compactMap(Anniversary.init(realmObject:))
    self.friendList = realmObject.friendList.compactMap(Friend.init(realmObject:))
    self.givenGifts = realmObject.givenGifts
    self.receivedGifts = realmObject.receivedGifts
    self.totalgifts = realmObject.totalGifts
    // TODO: 이미지 구현 후 적용
//    self.profilePhoto = realmObject.userPhoto
//    self.profileBackgroundPhoto = realmObject.backgroundPhoto
  }

  public func realmObject() -> UserObject {
    UserObject(
      userNo: self.identifier,
      email: self.email,
      userID: self.searchID,
      name: self.name,
      favorList: self.favorList.map { $0.rawValue },
      anniversaryList: self.anniversaryList.compactMap { $0.realmObject() },
      friendList: self.friendList.compactMap { $0.realmObject() },
      givenGifts: self.givenGifts,
      receivedGifts: self.receivedGifts,
      totalGifts: self.totalgifts
//      userPhoto: self.profilePhoto,
//      backgroundPhoto: self.profileBackgroundPhoto
    )
  }

  // MARK: - Receivable

  public init(dto: UserResponseDTO) {
    self.identifier = dto.userNo
    self.email = dto.email
    self.searchID = dto.userID
    self.name = dto.name
    self.favorList = dto.favorList.compactMap(Favor.init(rawValue:))
    self.reminderList = dto.reminderList.compactMap(Reminder.init(dto:))
    self.anniversaryList = dto.anniversaryList.compactMap(Anniversary.init(dto:))
    self.friendList = dto.friendList.compactMap(Friend.init(dto:))
    self.givenGifts = dto.givenGift
    self.receivedGifts = dto.receivedGift
    self.totalgifts = dto.totalGift
  }

  // MARK: - Mock

  /// 비어있는 구조체를 생성합니다.
  ///
  /// > **⚠️ Warning** :
  ///   `identifier` 값을 -1로 줍니다. 값을 임시로 담을 때만 사용해주세요.
  public init() {
    self.identifier = -1
    self.email = ""
    self.searchID = ""
    self.name = ""
    self.favorList = []
    self.reminderList = []
    self.anniversaryList = []
    self.friendList = []
    self.givenGifts = 0
    self.receivedGifts = 0
    self.totalgifts = 0
  }
}

// MARK: - PropertyValue

extension User {
  public enum PropertyValue: PropertyValueType {
    case identifier(Int)
    case email(String)
    case searchID(String)
    case name(String)
    case favorList([Favor])
    case reminderList([Reminder])
    case anniversaryList([Anniversary])
    case friendList([Friend])
    case profilePhoto(UIImage?)
    case profileBackgroundPhoto(UIImage?)
    case givenGifts(Int)
    case receivedGifts(Int)
    case totalGifts(Int)

    public var propertyValuePair: PropertyValuePair {
      switch self {
      case .identifier(let identifier):
        return ("identifier", identifier)
      case .email(let email):
        return ("email", email)
      case .searchID(let searchID):
        return ("searchID", searchID)
      case .name(let name):
        return ("name", name)
      case .favorList(let favorList):
        return ("favorList", favorList)
      case .reminderList(let reminderList):
        return ("reminderList", reminderList)
      case .anniversaryList(let anniversaryList):
        return ("anniversaryList", anniversaryList)
      case .friendList(let friendList):
        return ("friendList", friendList)
      case .profilePhoto(let profilePhoto):
        return ("profilePhoto", profilePhoto)
      case .profileBackgroundPhoto(let profileBackgroundPhoto):
        return ("profileBackgroundPhoto", profileBackgroundPhoto)
      case .givenGifts(let givenGifts):
        return ("givenGifts", givenGifts)
      case .receivedGifts(let receivedGifts):
        return ("receivedGifts", receivedGifts)
      case .totalGifts(let totalGifts):
        return ("totalGifts", totalGifts)
      }
    }
  }
}

// MARK: - Hashable

extension User: Hashable {
  public static func == (lhs: User, rhs: User) -> Bool {
    return lhs.identifier == rhs.identifier
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.identifier)
  }
}

// MARK: - Image Cache

extension FavorKit.CacheKeyMapper {
  public enum UserSubpath: String {
    case background
    case profilePhoto
  }
  
  public init(user: User, subpath: UserSubpath) {
    let key: String = "user/\(user.identifier)/\(subpath.rawValue)"
    var mapper = CacheKeyMapper(key: key, cacheType: .disk)
    switch subpath {
    case .background:
      mapper.preferredSize = ImageCacheManager.Metric.bannerSize
    case .profilePhoto:
      mapper.preferredSize = ImageCacheManager.Metric.profileSize
    }
    self = mapper
  }
}
