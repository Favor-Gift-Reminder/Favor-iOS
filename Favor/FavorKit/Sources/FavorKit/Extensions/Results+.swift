//
//  Results.swift
//  Favor
//
//  Created by 이창준 on 2023/03/27.
//

import Foundation

import RealmSwift

extension Results {
  public func toArray() async -> [Element] {
    return await withCheckedContinuation { continuation in
      DispatchQueue.realmThread.async {
        continuation.resume(returning: Array(self))
      }
    }
  }
}
