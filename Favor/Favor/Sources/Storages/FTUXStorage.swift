//
//  FTUXStorage.swift
//  Favor
//
//  Created by 김응철 on 2023/02/01.
//

import Foundation

final class FTUXStorage {
  
  private let key = "LAUNCHED_BEFORE"
  private let userDefaults = UserDefaults.standard
  
  var isFirstLaunched: Bool {
    return userDefaults.bool(forKey: key)
  }
  
  func setFirstLaunch() {
    userDefaults.set(true, forKey: key)
  }
}
