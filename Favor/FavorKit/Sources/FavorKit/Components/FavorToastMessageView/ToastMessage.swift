//
//  ToastMessage.swift
//  
//
//  Created by 이창준 on 2023/05/22.
//

import Foundation

public enum ToastMessage {

  // MARK: - Anniversary List

  case anniversaryModifed(String)

  // MARK: - Custom

  case custom(String?)
}

extension ToastMessage {
  public var description: String? {
    switch self {
    case .anniversaryModifed(let anniversaryTitle):
      return "\(anniversaryTitle) 수정 완료!"

    case .custom(let text):
      return text
    }
  }
}
