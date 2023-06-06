//
//  ToastMessage.swift
//  
//
//  Created by 이창준 on 2023/05/22.
//

import Foundation

public enum ToastMessage {

  // MARK: - Gift

  case giftEdited(String)
  case giftDeleted(String)

  // MARK: - Anniversary List

  case anniversaryAdded(String)
  case anniversaryModifed(String)
  case anniversaryDeleted(String)

  // MARK: - Custom

  case custom(String?)
}

extension ToastMessage {
  public var description: String? {
    switch self {
    case .giftEdited(let giftName):
      return "\"\(giftName)\" 수정 완료!"
    case .giftDeleted(let giftName):
      return "\"\(giftName)\" 삭제 완료!"

    case .anniversaryAdded(let anniversaryTitle):
      return "\"\(anniversaryTitle)\" 추가 완료!"
    case .anniversaryModifed(let anniversaryTitle):
      return "\"\(anniversaryTitle)\" 수정 완료!"
    case .anniversaryDeleted(let anniversaryTitle):
      return "\"\(anniversaryTitle)\" 삭제 완료!"

    case .custom(let text):
      return text
    }
  }
}
