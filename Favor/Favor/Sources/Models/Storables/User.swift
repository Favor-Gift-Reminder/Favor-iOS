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
  public var giftList: [Gift]
  public var reminderList: [Reminder]
  public var anniversaryList: [Anniversary]
  public var friendList: [Friend]
  public var profilePhoto: UIImage?
  public var profileBackgroundPhoto: UIImage?

  // MARK: - Storable

  public init(realmObject: UserObject) {
    @ThreadSafe var rlmObjectRef = realmObject
    guard let realmObject = rlmObjectRef else { fatalError() }
    
    self.identifier = realmObject.userNo
    self.email = realmObject.email
    self.searchID = realmObject.userID
    self.name = realmObject.name
    self.favorList = realmObject.favorList.toArray().compactMap { Favor(rawValue: $0) }
    self.giftList = realmObject.giftList.compactMap(Gift.init(realmObject:))
    self.reminderList = realmObject.reminderList.compactMap(Reminder.init(realmObject:))
    self.anniversaryList = realmObject.anniversaryList.compactMap(Anniversary.init(realmObject:))
    self.friendList = realmObject.friendList.compactMap(Friend.init(realmObject:))
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
      giftList: self.giftList.compactMap { $0.realmObject() },
      anniversaryList: self.anniversaryList.compactMap { $0.realmObject() },
      friendList: self.friendList.compactMap { $0.realmObject() }
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
    self.giftList = dto.giftList.compactMap(Gift.init(dto:))
    self.reminderList = dto.reminderList.compactMap(Reminder.init(dto:))
    self.anniversaryList = dto.anniversaryList.compactMap(Anniversary.init(dto:))
    self.friendList = dto.friendList.compactMap(Friend.init(dto:))
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
    self.giftList = []
    self.reminderList = []
    self.anniversaryList = []
    self.friendList = []
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
    case giftList([Gift])
    case reminderList([Reminder])
    case anniversaryList([Anniversary])
    case friendList([Friend])
    case profilePhoto(UIImage?)
    case profileBackgroundPhoto(UIImage?)

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
      case .giftList(let giftList):
        return ("giftList", giftList)
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
      }
    }
  }
}
