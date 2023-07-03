//
//  KeypadInput.swift
//  Favor
//
//  Created by 이창준 on 6/29/23.
//

public struct KeypadInput {
  public var data: Int?
  public var isLastInput: Bool

  public init(data: Int? = nil, isLastInput: Bool) {
    self.data = data
    self.isLastInput = isLastInput
  }
}

// MARK: - Array Extension

extension Array where Element == KeypadInput {
  public var combinedValue: String {
    let datas = self.compactMap { $0.data }.map { String($0) }
    return datas.joined()
  }
}
