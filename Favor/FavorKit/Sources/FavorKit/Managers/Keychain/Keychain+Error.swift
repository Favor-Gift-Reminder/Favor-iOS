//
//  Keychain+Error.swift
//  Favor
//
//  Created by 이창준 on 6/21/23.
//

import Foundation

extension KeychainManager {
  public enum KeychainError: Error {
    case fetchError
    case creationError
    case transactionError
  }
}
