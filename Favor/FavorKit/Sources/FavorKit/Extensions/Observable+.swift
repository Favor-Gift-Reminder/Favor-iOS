//
//  File.swift
//
//
//  Created by 김응철 on 11/1/23.
//

import Foundation

import RxSwift
import Moya

extension Observable where Element == Response {
  @discardableResult
  public func toAsync() async throws -> Element {
    return try await withCheckedThrowingContinuation { continuation in
      _ = self.subscribe { event in
        switch event {
        case .next(let element):
          continuation.resume(returning: element)
        case .error(let error):
          continuation.resume(throwing: error)
        case .completed:
          break
        }
      }
    }
  }
}
