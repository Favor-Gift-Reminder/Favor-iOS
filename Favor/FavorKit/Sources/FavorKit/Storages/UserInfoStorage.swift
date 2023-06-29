//
//  UserInfoStorage.swift
//  Favor
//
//  Created by 이창준 on 2023/04/20.
//

import Foundation

public final class UserInfoStorage {
  @UserDefault(key: .userNo, defaultValue: -1)
  public static var userNo: Int

  @UserDefault(key: .isLocalAuthEnabled, defaultValue: false)
  public static var isLocalAuthEnabled: Bool

  @UserDefault(key: .isBiometricAuthEnabled, defaultValue: false)
  public static var isBiometricAuthEnabled: Bool
}
