//
//  ToastMessage.swift
//  
//
//  Created by 이창준 on 2023/05/22.
//

import Foundation

/// 토스트 메세지의 배경색이 다른 두 ViewType입니다.
///
/// `warning`은 경고 아이콘과 함께 빨간색 배경화면의 View입니다.
/// `basic`은 일반 그레이 색상의 View입니다.
public enum ToastViewType {
  case basic
  case warning
}

public enum ToastMessage {
  
  // MARK: - Gift

  case giftEdited(String)
  case giftDeleted(String)

  // MARK: - Anniversary List
  
  case anniversaryAdded(String)
  case anniversaryModifed(String)
  case anniversaryDeleted(String)
  case anniversaryPinLimited
  
  // MARK: - Reminder
  
  case reminderAdded
  
  // MARK: - Network
  
  case networkStatus

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
    case .anniversaryPinLimited:
      return "최대 3개까지 고정 가능합니다."
      
    case .reminderAdded:
      return "리마인더가 등록되었습니다."
      
    case .networkStatus:
      return "인터넷 상태가 불안정합니다."

    case .custom(let text):
      return text
    }
  }
  
  public var viewType: ToastViewType {
    switch self {
    case .anniversaryPinLimited:
      return .warning
    case .networkStatus:
      return .warning
    default:
      return .basic
    }
  }
  
  public var bottomInset: CGFloat {
    switch self {
    case .anniversaryPinLimited:
      return 94.0
    default:
      return 46.0
    }
  }
}
