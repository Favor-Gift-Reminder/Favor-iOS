//
//  FavorRealmMigration.swift
//  Favor
//
//  Created by 이창준 on 2023/06/05.
//

import Foundation

import RealmSwift

public struct FavorRealmMigration {
  public var migrationBlock: MigrationBlock = { migration, oldVersion in
    if oldVersion < 4 {
      migration.enumerateObjects(ofType: SearchRecent.className(), { oldObject, newObject in
        let searchText = oldObject!["searchText"] as! String
        let searchDate = oldObject!["searchDate"] as! Date
        newObject!["searchText"] = searchText
        newObject!["searchDate"] = searchDate
      })
    }
    if oldVersion < 5 {
      migration.enumerateObjects(ofType: User.className(), { oldObject, newObject in
        let favorList = oldObject!["favorList"] as! [Int]
        newObject!["favorList"] = favorList
      })
    }
    if oldVersion < 6 {
      migration.enumerateObjects(ofType: User.className(), { _, newObject in
        newObject!["anniversaryList"] = List<Anniversary>()
      })
    }
    if oldVersion < 7 {
      migration.enumerateObjects(ofType: Gift.className(), { oldObject, newObject in
        let giftCategory = oldObject!["category"]
        let giftEmotion = oldObject!["emotion"]
        newObject!["category"] = giftCategory
        newObject!["emotion"] = giftEmotion
      })
    }
    if oldVersion < 8 {
      migration.enumerateObjects(ofType: Friend.className()) { _, newObject in
        newObject!["anniversaryList"] = List<Anniversary>()
        newObject!["favorList"] = List<String>()
      }
    }
    if oldVersion < 9 {
      migration.enumerateObjects(ofType: Gift.className()) { _, newObject in
        newObject!["privateCategory"] = "가벼운선물"
      }
    }
    if oldVersion < 10 {
      migration.enumerateObjects(ofType: Gift.className()) { _, newObject in
        newObject!["privateCategory"] = "가벼운선물"
      }
    }
  }
}
