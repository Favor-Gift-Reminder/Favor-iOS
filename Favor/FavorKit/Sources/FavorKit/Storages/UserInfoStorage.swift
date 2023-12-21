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
  @UserDefault(key: .isBiometricAuthEnabled, defaultValue: false)
  public static var isBiometricAuthEnabled: Bool

  /// 리마인더 알림 여부 Boolean
  @UserDefault(key: .isReminderNotificationEnabled, defaultValue: false)
  public static var isReminderNotificationEnabled: Bool

  /// 마케팅 정보 알림
  @UserDefault(key: .isMarketingNotificationEnabled, defaultValue: false)
  public static var isMarketingNotificationEnabled: Bool
  
  public static func deleteAll() {
    UserInfoStorage.userNo = -1
    UserInfoStorage.isLocalAuthEnabled = false
    UserInfoStorage.isBiometricAuthEnabled = false
    UserInfoStorage.isReminderNotificationEnabled = true
    UserInfoStorage.isMarketingNotificationEnabled = true
  }
}
