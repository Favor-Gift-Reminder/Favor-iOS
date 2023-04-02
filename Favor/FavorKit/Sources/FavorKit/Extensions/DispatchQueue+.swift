//
//  DispatchQueue+.swift
//  Favor
//
//  Created by 이창준 on 2023/03/26.
//

import Foundation

public extension DispatchQueue {
  static let realmThread = DispatchQueue(
    label: "com.favor.Favor-iOS.realm",
    qos: .userInitiated
  )
}
