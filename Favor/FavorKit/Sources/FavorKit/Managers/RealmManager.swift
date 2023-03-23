//
//  RealmManager.swift
//  Favor
//
//  Created by 이창준 on 2023/03/19.
//

import OSLog

import RealmSwift
import RxRealm

protocol RealmCRUDable {
  func create<T: Object>(_ object: T, _ errorHandler: @escaping (_ error: Error) -> Void)
  func read<T: Object>(_ object: T.Type) -> Results<T>
  func update<T: Object>(_ object: T, _ errorHandler: @escaping (_ error: Error) -> Void)
  func delete<T: Object>(_ object: T, _ errorHandler: @escaping (_ error: Error) -> Void)
}

public final class RealmManager: RealmCRUDable {

  // MARK: - Properties

  // Singleton
  public static let shared = RealmManager()

  /// 로컬 DB의 버전
  ///
  /// [~ Version History ~](https://www.notion.so/RealmDB-e1b9de8fcc784a2e9e13e0e1b15e4fed?pvs=4)
  private static let version: UInt64 = 2

  /// RealmManager에서 사용될 realm 인스턴스
  private let realm: Realm

  // MARK: - Initializer

  private init() {
    let config = Realm.Configuration(
      schemaVersion: RealmManager.version
    )
    do {
      let realm = try Realm(configuration: config)
      self.realm = realm
    } catch {
      fatalError(
        """
        Failed to create Realm instance with config: \(config), \
        Error Message: \(error.localizedDescription)
        """
      )
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
  /// let user = User(userID: 0, userName = "페이버")
  /// RealmManager.shared.create(user)
  /// ```
  ///
  /// - Parameters:
  ///   - object: 추가할 `RealmObject` 인스턴스
  ///   - errorHandler: RealmDB에 주어진 인스턴스를 추가하지 못했을 때 호출되는 `@escaping` 클로저
  public func create<T: Object>(
    _ object: T,
    _ errorHandler: @escaping (_ error: Error) -> Void = { _ in return }
  ) {
    do {
      try self.realm.write {
        self.realm.add(object)
      }
    } catch {
      errorHandler(error)
    }
  }

  /// RealmDB에서 주어진 `RealmObject`의 값들을 읽어옵니다.
  ///
  /// **Usage**
  /// ``` Swift
  /// let users = RealmManager.shared.read(User.self)
  /// ```
  ///
  /// - Parameters:
  ///   - objectType: 읽어올 `RealmObject`의 클래스 타입
  /// - Returns: 주어진 `RealmObject` 클래스 타입의 모든 값을 읽어온 `Results`
  public func read<T: Object>(_ objectType: T.Type) -> Results<T> {
    return self.realm.objects(objectType)
  }

  /// RealmDB에서 주어진 PK 값의 `RealmObject` 인스턴스를 읽어옵니다.
  ///
  /// **Usage**
  /// ``` Swift
  /// let user = RealmManager.shared.read(User.self, forPrimaryKey: 1)
  /// ```
  ///
  /// - Parameters:
  ///   - objectType: 읽어올 `RealmObject`의 클래스 타입
  ///   - pk: 읽어올 인스턴스의 Primary Key
  /// - Returns:주어진 `RealmObject` 클래스 타입에서 `pk` 값의 인스턴스
  public func read<T: Object>(
    _ objectType: T.Type,
    forPrimaryKey pk: UInt64
  ) -> T? {
    return self.realm.object(ofType: objectType, forPrimaryKey: pk)
  }

  /// RealmDB에 존재하는 `RealmObject` 인스턴스의 값을 업데이트합니다.
  /// 만약 값이 없다면, 새로운 인스턴스로 추가합니다.
  ///
  /// **Usage**
  /// ``` Swift
  /// let gift = RealmManager.shared.realm.object(ofType: Gift.self, forPrimaryKey: 1)
  /// gift.isPinned.toggle()
  /// RealmManager.shared.update(gift)
  /// ```
  ///
  /// - Parameters:
  ///   - object: 업데이트할 `RealmObject` 인스턴스
  ///   - errorHandler: RealmDB에 주어진 인스턴스를 업데이트하지 못했을 때 호출되는 `@escaping` 클로저
  public func update<T: Object>(
    _ object: T,
    _ errorHandler: @escaping (_ error: Error) -> Void = { _ in return }
  ) {
    do {
      try self.realm.write {
        self.realm.add(object, update: .modified)
      }
    } catch {
      errorHandler(error)
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
  public func updateAll<T: Object>(
    _ objects: [T],
  _ errorHandler: @escaping (_ error: Error) -> Void = { _ in return }
  ) {
    do {
      try self.realm.write {
        self.realm.add(objects, update: .modified)
      }
    } catch {
      errorHandler(error)
    }
  }

  /// RealmDB에 존재하는 인스턴스를 삭제합니다.
  ///
  /// **Usage**
  /// ``` Swift
  /// let user = User(userID: 1, userName: "페이버")
  /// RealmManager.shared.delete(user)
  /// ```
  ///
  /// - Parameters:
  ///   - object: 삭제할 `RealmObject` 인스턴스
  ///   - errorHandler: RealmDB에 주어진 인스턴스를 삭제하지 못했을 때 호출되는 `@escaping` 클로저
  public func delete<T: Object>(
    _ object: T,
    _ errorHandler: @escaping (_ error: Error) -> Void = { _ in return }
  ) {
    do {
      try self.realm.write {
        self.realm.delete(object)
      }
    } catch {
      errorHandler(error)
    }
  }

  /// RealmDB에 존재하는 모든 값을 삭제합니다.
  ///
  /// **⚠️ CAUTION**
  ///
  /// 말 그대로 모든 값을 삭제합니다. 클래스와 타입에 상관 없이요. 사용에 유의해주세요.
  ///
  /// - Parameters:
  ///   - errorHandler: RealmDB에 주어진 인스턴스를 삭제하지 못했을 때 호출되는 `@escaping` 클로저
  public func deleteAll(_ errorHandler: @escaping (_ error: Error) -> Void = { _ in return }) {
    do {
      try self.realm.write {
        self.realm.deleteAll()
      }
    } catch {
      errorHandler(error)
    }
  }
}
