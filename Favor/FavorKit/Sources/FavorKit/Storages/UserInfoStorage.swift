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

  /// 앱 잠금 자체에 대한 활성화 여부 Boolean
  @UserDefault(key: .isLocalAuthEnabled, defaultValue: false)
  public static var isLocalAuthEnabled: Bool

  /// 앱 잠금에 생체 인식 사용 여부 Boolean
  @UserDefault(key: .isBiometricAuthEnabled, defaultValue: nil)
  public static var isBiometricAuthEnabled: Bool?
}
