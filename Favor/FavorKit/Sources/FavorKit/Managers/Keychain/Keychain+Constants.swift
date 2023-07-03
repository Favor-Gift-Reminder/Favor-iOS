//
//  Keychain+Constants.swift
//  Favor
//
//  Created by 이창준 on 6/21/23.
//

extension KeychainManager {

  enum Constants {
    static let service: String = "com.favor.Favor.iOS.keychainManager"
  }

  public enum Accounts: String, CaseIterable {
    case userAppleID = "com.favor.Favor.iOS.keychainManager.userAppleID"
    case accessToken = "com.favor.Favor.iOS.keychainManager.accessToken"
    case userEmail = "com.favor.Favor.iOS.keychainManager.email"
    case userPassword = "com.favor.Favor.iOS.keychainManager.password"

    case localAuth = "com.favor.Favor.iOS.keychainManager.localAuth"
  }
}
