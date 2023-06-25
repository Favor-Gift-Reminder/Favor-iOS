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

  public enum Accounts: String {
    case userID = "com.favor.Favor.iOS.keychainManager.userID"
    case accessToken = "com.favor.Favor.iOS.kehchainManager.accessToken"
  }
}
