//
//  RealmActor.swift
//  Favor
//
//  Created by 이창준 on 2023/06/05.
//

import Foundation

import RealmSwift

/// Actor 내부의 프로퍼티들은 여러개의 Task로부터 동시적으로 접근되지 않습니다.
/// Realm의 데이터들을 Data Race로부터 보호합니다.
public actor RealmActor {

  // MARK: - Properties

  private var realm: Realm!

  private let version: UInt64 = 11
  private let migration = FavorRealmMigration()

  // MARK: - Initializer

  public init() async throws {
    do {
      self.realm = try await Realm(
        configuration: Realm.Configuration(
          schemaVersion: self.version,
          migrationBlock: self.migration.migrationBlock
        ),
        actor: self
      )
    } catch {
      fatalError("Failed to create Realm instance: \(error.localizedDescription)")
    }
  }

  public func close() {
    self.realm = nil
  }
}

// MARK: - Functions

public extension RealmActor {

}
