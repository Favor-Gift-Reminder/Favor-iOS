//
//  RealmMigration.swift
//  Favor
//
//  Created by 이창준 on 2023/06/05.
//

import Foundation

import RealmSwift

public class RealmMigration {

  // MARK: - Properties

  /// Realm DB의 Scheme 버전
  ///
  /// [**Version History**](https://www.notion.so/RealmDB-e1b9de8fcc784a2e9e13e0e1b15e4fed?pvs=4)
  public static let version: UInt64 = 13
  
  public var migrationBlock: MigrationBlock = { migration, oldVersion in
    guard oldVersion < RealmMigration.version else {
      fatalError("RealmDB versioning error.")
    }

    if oldVersion < 4 {
      migration.enumerateObjects(ofType: RecentSearchObject.className(), { oldObject, newObject in
        let searchText = oldObject!["searchText"] as! String
        let searchDate = oldObject!["searchDate"] as! Date
        newObject!["searchText"] = searchText
        newObject!["searchDate"] = searchDate
      })
    }
    if oldVersion < 5 {
      migration.enumerateObjects(ofType: UserObject.className(), { oldObject, newObject in
        let favorList = oldObject!["favorList"] as! [Int]
        newObject!["favorList"] = favorList
      })
    }
    if oldVersion < 6 {
      migration.enumerateObjects(ofType: UserObject.className(), { _, newObject in
        newObject!["anniversaryList"] = List<AnniversaryObject>()
      })
    }
    if oldVersion < 7 {
      migration.enumerateObjects(ofType: GiftObject.className(), { oldObject, newObject in
        let giftCategory = oldObject!["category"]
        let giftEmotion = oldObject!["emotion"]
        newObject!["category"] = giftCategory
        newObject!["emotion"] = giftEmotion
      })
    }
    if oldVersion < 8 {
      migration.enumerateObjects(ofType: FriendObject.className()) { _, newObject in
        newObject!["anniversaryList"] = List<AnniversaryObject>()
        newObject!["favorList"] = List<String>()
      }
    }
    if oldVersion < 9 {
      migration.enumerateObjects(ofType: GiftObject.className()) { _, newObject in
        newObject!["privateCategory"] = "가벼운선물"
      }
    }
    if oldVersion < 10 {
      migration.enumerateObjects(ofType: GiftObject.className()) { _, newObject in
        newObject!["privateCategory"] = "가벼운선물"
      }
    }
    if oldVersion < 12 {
      migration.enumerateObjects(ofType: UserObject.className()) { _, newObject in
        newObject!["givenGifts"] = 0
        newObject!["receivedGifts"] = 0
        newObject!["totalGifts"] = 0
      }
    }
    if oldVersion < 13 {
      migration.enumerateObjects(ofType: PhotoObject.className()) { _, newObject in
        newObject!["local"] = ""
      }
    }
  }
  
  // MARK: - Initializer
  
  public init() { }
}
