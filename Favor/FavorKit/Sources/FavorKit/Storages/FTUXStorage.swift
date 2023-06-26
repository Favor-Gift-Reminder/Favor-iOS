//
//  FTUXStorage.swift
//  Favor
//
//  Created by 김응철 on 2023/02/01.
//

import Foundation

public final class FTUXStorage {
  @UserDefault(key: .isFirstLaunch, defaultValue: true)
  public static var isFirstLaunch: Bool
  
  @UserDefault(key: .isSignedIn, defaultValue: false)
  public static var isSignedIn: Bool

  @UserDefault(key: .socialAuthType, defaultValue: .undefined)
  public static var socialAuthType: AuthMethod
}
