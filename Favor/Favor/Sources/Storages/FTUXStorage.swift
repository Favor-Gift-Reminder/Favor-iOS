//
//  FTUXStorage.swift
//  Favor
//
//  Created by 김응철 on 2023/02/01.
//

import Foundation

final class FTUXStorage {
  @UserDefault(key: .isFirstLaunch, defaultValue: true)
  static var isFirstLaunch: Bool
  
  @UserDefault(key: .isSignedIn, defaultValue: false)
  static var isSignedIn: Bool
}
