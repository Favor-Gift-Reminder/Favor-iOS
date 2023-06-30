//
//  Keychain+Transactions.swift
//  Favor
//
//  Created by 이창준 on 6/24/23.
//

import Foundation
import OSLog

extension KeychainManager {
  
  /// **kSecClass**
  /// `kSecClassGenericPassword`
  /// - 일반적인 비밀번호 (주어진 데이터만)
  /// `kSecClassInternetPassword`
  /// - 인터넷 비밀번호
  /// - URL, username 등을 함께 저장
  /// `kSecClassCertificate`
  /// - 인증서 (Certificate 파일)
  /// `kSecClassKey`
  /// - 암호화 키 (en/decrypt를 위한 Key)
  /// `kSecClassIdentity`
  /// - ID (Certificate + PrivateKey)
  /// ➡️ 대부분의 경우 GenericPassword를 사용하면 됨!

  /// Keychain으로부터 데이터를 불러옵니다.
  /// - Parameters:
  ///   - account: 가져올 키체인의 Key (`String`)
  internal func fetch(account: String) throws -> Data? {
    var result: AnyObject?

    let status = SecItemCopyMatching([
      kSecClass: kSecClassGenericPassword,
      kSecAttrAccount: account,
      kSecAttrService: Constants.service,
      kSecReturnData: true
    ] as NSDictionary, &result)

    switch status {
    case errSecSuccess:
      return result as? Data
    case errSecItemNotFound:
      return nil
    default:
      throw KeychainError.fetchError
    }
  }

  /// Keychain에 데이터를 저장합니다.
  /// - Parameters:
  ///   - value: 저장할 값 (`Data`)
  ///   - account: 저장할 값에 대응되는 Key (`String`)
  internal func add(value: Data, account: String) throws {
    let status = SecItemAdd([
      kSecClass: kSecClassGenericPassword, // 데이터 종류
      kSecAttrAccount: account, // 데이터 키
      kSecValueData: value, // 데이터 밸류
      kSecAttrService: Constants.service
    ] as NSDictionary, nil)

    guard status == errSecSuccess else { throw KeychainError.transactionError }
  }

  /// Keychain에 있는 데이터를 업데이트합니다.
  /// - Parameters:
  ///   - value: 업데이트할 값 (`Data`)
  ///   - account: 업데이트할 값에 대응되는 Key (`String`)
  internal func update(value: Data, account: String) throws {
    let status = SecItemUpdate([
      kSecClass: kSecClassGenericPassword,
      kSecAttrAccount: account,
      kSecAttrService: Constants.service
    ] as NSDictionary, [
      kSecValueData: value
    ] as NSDictionary)

    guard status == errSecSuccess else { throw KeychainError.transactionError}
  }

  /// Keychain에 있는 데이터를 삭제합니다.
  /// - Parameters:
  ///   - account: 삭제할 값에 대응되는 Key (`String`)
  internal func remove(account: String) throws {
    let status = SecItemDelete([
      kSecClass: kSecClassGenericPassword,
      kSecAttrAccount: account,
      kSecAttrService: Constants.service
    ] as NSDictionary)

    guard status == errSecSuccess else { throw KeychainError.transactionError }
  }

  /// Keychain에 account에 대응되는 값이 존재하는지 확인합니다.
  /// - Parameters:
  ///   - account: 조회할 Key (`String`)
  internal func exists(account: String) throws -> Bool {
    let status = SecItemCopyMatching([
      kSecClass: kSecClassGenericPassword,
      kSecAttrAccount: account,
      kSecAttrService: Constants.service,
      kSecReturnData: false
    ] as NSDictionary, nil)

    switch status {
    case errSecSuccess:
      os_log(.debug, "🔑 Found Keychain value for account: \(account)")
      return true
    case errSecItemNotFound:
      return false
    default:
      throw KeychainError.creationError
    }
  }
}
