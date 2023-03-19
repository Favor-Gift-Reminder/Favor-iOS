//
//  RealmManager.swift
//  Favor
//
//  Created by 이창준 on 2023/03/19.
//

import Foundation

import RealmSwift

public final class RealmManager {

  // MARK: - Properties

  // Singleton
  public static let shared = RealmManager()

  /// 로컬 DB의 버전
  ///
  /// [Version History](https://www.notion.so/RealmDB-e1b9de8fcc784a2e9e13e0e1b15e4fed?pvs=4)
  private static let version: UInt64 = 2

  // MARK: - Initializer

  private init() { }

  // MARK: - Functions

  /// 앱 Launch 시 RealmDB를 불러옵니다.
  public func initRealm() {
    func setupRealm() {
      let config = Realm.Configuration(
        schemaVersion: RealmManager.version
      )
      Realm.Configuration.defaultConfiguration = config
      let realm = try! Realm()
      print("Realm is located at", realm.configuration.fileURL!)
    }
  }
}
