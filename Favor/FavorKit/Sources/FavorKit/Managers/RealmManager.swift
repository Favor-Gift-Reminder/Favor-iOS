//
//  RealmManager.swift
//  Favor
//
//  Created by 이창준 on 2023/03/19.
//

import OSLog

import RealmSwift

protocol RealmCRUDable {
  func create<T: Object>(_ object: T) async throws -> T
  func read<T: Object>(_ objectType: T.Type) async throws -> Results<T>
  func update<T: Object>(_ object: T) async throws -> T
  func delete<T: Object>(_ object: T) async throws -> T
}

public final class RealmManager: RealmCRUDable {

  // MARK: - Properties

  // Singleton
  public static let shared = RealmManager()

  /// 로컬 DB의 버전
  ///
  /// [~ Version History ~](https://www.notion.so/RealmDB-e1b9de8fcc784a2e9e13e0e1b15e4fed?pvs=4)
  private static let version: UInt64 = 4

  /// RealmManager에서 사용될 realm 인스턴스
  private var realm: Realm!
  /// Realm의 transaction은 해당 realm 인스턴스가 생성된 쓰레드에서 이루어져야 합니다.
  private let realmQueue = DispatchQueue.realmThread

  // MARK: - Initializer

  private init() {
    do {
      let config = Realm.Configuration(
        schemaVersion: RealmManager.version
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
    os_log(.debug, "💽 Realm is located at \(self.realm.configuration.fileURL!)")
  }

  /// RealmDB에 데이터를 추가합니다.
  ///
  /// **Usage**
  /// ``` Swift
  /// Task {
  ///   let user = User(userID: 0, userName = "페이버")
  ///   do {
  ///     try await RealmManager.shared.create(user)
  ///   } catch {
  ///     fatalError(error)
  ///   }
  /// }
  /// ```
  ///
  /// - Parameters:
  ///   - object: 추가할 `RealmObject` 인스턴스
  /// - Returns: ***@Discardable*** 추가된 `RealmObject`
  @discardableResult
  public func create<T: Object>(_ object: T) async throws -> T {
    typealias RealmContinuation = CheckedContinuation<T, Error>
    return try await withCheckedThrowingContinuation { (continuation: RealmContinuation) in
      self.realmQueue.async {
        do {
          try self.realm.write {
            self.realm.add(object)
          }
          continuation.resume(returning: object.freeze())
        } catch {
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// RealmDB에서 주어진 `RealmObject`의 값들을 읽어옵니다.
  ///
  /// **Usage**
  /// ``` Swift
  /// Task {
  ///   do {
  ///     let users = try await RealmManager.shared.read(User.self)
  ///   } catch {
  ///     fatalError(error)
  ///   }
  /// }
  /// ```
  ///
  /// - Parameters:
  ///   - objectType: 읽어올 `RealmObject`의 클래스 타입
  /// - Returns: 주어진 `RealmObject` 클래스 타입의 모든 값을 읽어온 `Results`
  public func read<T: Object>(_ objectType: T.Type) async throws -> Results<T> {
    typealias RealmContinuation = CheckedContinuation<Results<T>, Error>
    return try await withCheckedThrowingContinuation { (continuation: RealmContinuation) in
      self.realmQueue.async {
        let frozenRealm = self.realm.freeze()
        let frozenObjects = frozenRealm.objects(objectType)
        continuation.resume(returning: frozenObjects)
      }
    }
  }

  /// RealmDB에서 주어진 PK 값의 `RealmObject` 인스턴스를 읽어옵니다.
  ///
  /// **Usage**
  /// ``` Swift
  /// Task {
  ///   let user = await RealmManager.shared.read(User.self, forPrimaryKey: 1)
  /// }
  /// ```
  ///
  /// - Parameters:
  ///   - objectType: 읽어올 `RealmObject`의 클래스 타입
  ///   - pk: 읽어올 인스턴스의 Primary Key
  /// - Returns:주어진 `RealmObject` 클래스 타입에서 `pk` 값의 인스턴스
  public func read<T: Object>(_ objectType: T.Type, forPrimaryKey pk: UInt64) async -> T? {
    return await withCheckedContinuation { continuation in
      self.realmQueue.async {
        let frozenRealm = self.realm.freeze()
        let frozenObject = frozenRealm.object(ofType: objectType, forPrimaryKey: pk)
        continuation.resume(returning: frozenObject)
      }
    }
  }

  /// RealmDB에 존재하는 `RealmObject` 인스턴스의 값을 업데이트합니다.
  /// 만약 값이 없다면, 새로운 인스턴스로 추가합니다.
  ///
  /// **Usage**
  /// ``` Swift
  /// Task {
  ///   let gift = await RealmManager.shared.read(Gift.self, forPrimaryKey: 1)
  ///   guard let gift else { return }
  ///   gift.isPinned.toggle()
  ///   do {
  ///     try await RealmManager.shared.update(gift)
  ///   } catch {
  ///     fatalError(error)
  ///   }
  /// }
  /// ```
  ///
  /// - Parameters:
  ///   - object: 업데이트할 `RealmObject` 인스턴스
  /// - Returns: ***@Discardable*** 업데이트한 `RealmObject` 인스턴스
  @discardableResult
  public func update<T: Object>(_ object: T) async throws -> T {
    typealias RealmContinuation = CheckedContinuation<T, Error>
    return try await withCheckedThrowingContinuation { (continuation: RealmContinuation) in
      self.realmQueue.async {
        do {
          try self.realm.write {
            self.realm.add(object, update: .modified)
          }
          continuation.resume(returning: object.freeze())
        } catch {
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// RealmDB에 존재하는 `RealmObject` 인스턴스의 값들을 업데이트합니다.
  /// 만약 값이 없다면, 새로운 인스턴스들로 추가합니다.
  ///
  /// **Usage**
  /// ``` Swift
  /// let gifts = networking.request(.getAllGifts)
  /// let decodedGifts: ResponseDTO<GiftResponseDTO.AllGifts> = APIManager.decode(gifts)
  /// RealmManager.shared.updateAll(gifts)
  /// ```
  ///
  /// - Parameters:
  ///   - objects: 업데이트할 `RealmObject` 인스턴스들의 컬렉션
  ///   - errorHandler: RealmDB에 주어진 인스턴스들을 업데이트하지 못했을 때 호출되는 `@escaping` 클로저
  /// - Returns: ***@Discardable*** 업데이트된 `RealmObject` 인스턴스들의 컬렉션
  @discardableResult
  public func updateAll<T: Object>(_ objects: [T]) async throws -> [T] {
    typealias RealmContinuation = CheckedContinuation<[T], Error>
    return try await withCheckedThrowingContinuation { (continuation: RealmContinuation) in
      self.realmQueue.async {
        do {
          try self.realm.write {
            self.realm.add(objects, update: .all)
          }
          let frozenObjects = objects.map { $0.freeze() }
          continuation.resume(returning: frozenObjects)
        } catch {
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// RealmDB에 존재하는 인스턴스를 삭제합니다.
  ///
  /// **Usage**
  /// ``` Swift
  /// Task {
  ///   do {
  ///     let user = User(userID: 1, userName: "페이버")
  ///     try await RealmManager.shared.delete(user)
  ///   } catch {
  ///     fatalError(error)
  ///   }
  /// }
  /// ```
  ///
  /// - Parameters:
  ///   - object: 삭제할 `RealmObject` 인스턴스
  /// - Returns: ***@Discardable*** 삭제한 `RealmObject` 인스턴스
  @discardableResult
  public func delete<T: Object>(_ object: T) async throws -> T {
    typealias RealmContinuation = CheckedContinuation<T, Error>
    return try await withCheckedThrowingContinuation { (continuation: RealmContinuation) in
      self.realmQueue.async {
        do {
          try self.realm.write {
            self.realm.delete(object)
          }
          continuation.resume(returning: object.freeze())
        } catch {
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// RealmDB에 존재하는 모든 값을 삭제합니다.
  ///
  /// **Usage**
  /// ``` Swift
  /// Task {
  ///   do {
  ///     try await RealmManager.shared.delete(user)
  ///   } catch {
  ///     fatalError(error)
  ///   }
  /// }
  /// ```
  ///
  /// - warning: 말 그대로 모든 값을 삭제합니다. 클래스와 타입에 상관 없이요. 사용에 유의해주세요.
  public func deleteAll() async throws {
    typealias RealmContinuation = CheckedContinuation<Never, Error>
    return try await withCheckedThrowingContinuation { continuation in
      self.realmQueue.async {
        do {
          try self.realm.write {
            self.realm.deleteAll()
          }
          continuation.resume(returning: ())
        } catch {
          continuation.resume(throwing: error)
        }
      }
    }
  }
}
