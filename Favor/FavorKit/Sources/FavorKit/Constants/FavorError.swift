//
//  FavorError.swift
//  Favor
//
//  Created by 이창준 on 2023/05/19.
//

public enum FavorError: Error {

  // MARK: - Foundation

  case optionalBindingFailure(Any?)
}

extension FavorError {
  public var description: String {
    switch self {
    case .optionalBindingFailure(let optionalValue):
      return "Optional value \(String(describing: optionalValue)) has no value."
    }
  }
}
