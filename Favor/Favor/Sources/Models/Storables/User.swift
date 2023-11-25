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
  public var profilePhoto: Photo?
  public var profileBackgroundPhoto: Photo?
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
    if let userPhotoObject = realmObject.userPhoto {
      self.profilePhoto =  Photo(realmObject: userPhotoObject)
    }
    if let backgroundPhotoObject = realmObject.backgroundPhoto {
      self.profileBackgroundPhoto = Photo(realmObject: backgroundPhotoObject)
    }
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
      userPhoto: self.profilePhoto?.realmObject(),
      backgroundPhoto: self.profileBackgroundPhoto?.realmObject(),
      givenGifts: self.givenGifts,
      receivedGifts: self.receivedGifts,
      totalGifts: self.totalgifts
    )
  }
  
  // MARK: - Receivable
  
  public init(singleDTO: UserSingleResponseDTO) {
    self.identifier = singleDTO.userNo
    self.email = singleDTO.email
    self.searchID = singleDTO.userID
    self.name = singleDTO.name
    self.favorList = singleDTO.favorList.compactMap(Favor.init(rawValue:))
    self.reminderList = singleDTO.reminderList.compactMap(Reminder.init(dto:))
    self.anniversaryList = singleDTO.anniversaryList.compactMap(Anniversary.init(singleDTO:))
    self.friendList = singleDTO.friendList.compactMap(Friend.init(friendResponseDTO:))
    self.givenGifts = singleDTO.givenGift
    self.receivedGifts = singleDTO.receivedGift
    self.totalgifts = singleDTO.totalGift
    if let profileBackgroundPhoto = singleDTO.userBackgroundUserPhoto {
      self.profileBackgroundPhoto = Photo(singleDTO: profileBackgroundPhoto)
    }
    if let profilePhoto = singleDTO.userProfileUserPhoto {
      self.profilePhoto = Photo(singleDTO: profilePhoto)
    }
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
  public enum UserSubpath {
    case background(String?)
    case profilePhoto(String?)
    
    public var rawValue: String {
      switch self {
      case .background: "background"
      case .profilePhoto: "profilePhoto"
      }
    }
    
    public var url: String {
      switch self {
      case .background(let url):
        return url ?? ""
      case .profilePhoto(let url):
        return url ?? ""
      }
    }
  }
  
  public init(user: User, subpath: UserSubpath) {
    let key: String = "user/\(user.identifier)/\(subpath.rawValue)/\(subpath.url)"
    var mapper = CacheKeyMapper(key: key, cacheType: .disk)
    mapper.url = subpath.url
    switch subpath {
    case .background:
      mapper.preferredSize = ImageCacheManager.Metric.bannerSize
    case .profilePhoto:
      mapper.preferredSize = ImageCacheManager.Metric.bannerSize
    }
    self = mapper
  }
}
