//
//  Keychain+Manager.swift
//  Favor
//
//  Created by 이창준 on 6/21/23.
//

import Foundation

public final class KeychainManager {

  public func add(value: Data, account: String) throws {
    let status = SecItemAdd([
      kSecClass: kSecClassGenericPassword
    ] as NSDictionary, nil)
    guard status == errSecSuccess else { throw KeychainError.transactionError }
  }
}
