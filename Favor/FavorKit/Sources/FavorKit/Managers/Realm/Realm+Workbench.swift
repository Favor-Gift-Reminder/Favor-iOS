//
//  Realm+Workbench.swift
//  Favor
//
//  Created by 이창준 on 6/6/23.
//

import Foundation
import OSLog

import RealmSwift

public final class RealmWorkbench {

  // MARK: - Properties

  private var realm: Realm!
  public let realmQueue: DispatchQueue

  private let migration = RealmMigration()

  // MARK: - Initializer

  public init(
    reset: Bool = false,
    queue: DispatchQueue = DispatchQueue.realmThread
  ) {
    self.realmQueue = queue

    do {
      let config = Realm.Configuration(
        schemaVersion: RealmMigration.version,
        migrationBlock: self.migration.migrationBlock
      )

      try self.realmQueue.sync {
        self.realm = try Realm(configuration: config, queue: self.realmQueue)
      }
    } catch {
      fatalError("Failed to create Realm instance: \(error.localizedDescription)")
    }
  }

  // MARK: - Functions

  /// RealmDB 파일의 위치를 출력합니다.
  public func locateRealm() {
    os_log(.debug, "💽 RealmDB is located at \(self.realm.configuration.fileURL!)")
  }

  public func write(
    _ block: @escaping (_ transaction: Transaction) throws -> Void
  ) async throws {
    typealias RealmContinuation = UnsafeContinuation<Void, Error>
    return try await withUnsafeThrowingContinuation { (continuation: RealmContinuation) in
      self.realmQueue.async {
        let transaction = Transaction(realm: self.realm)
        do {
          try self.realm.write {
            try block(transaction)
          }
          continuation.resume(returning: ())
        } catch {
          continuation.resume(throwing: error)
        }
      }
    }
  }

  public func values<T: Object>(
    _ type: T.Type
  ) async -> Results<T> {
    typealias RealmContinuation = CheckedContinuation<Results<T>, Never>
    return await withCheckedContinuation { (continuation: RealmContinuation) in
      self.realmQueue.async {
        let objects = self.realm.objects(type).freeze()
        continuation.resume(returning: objects)
      }
    }
  }
}
