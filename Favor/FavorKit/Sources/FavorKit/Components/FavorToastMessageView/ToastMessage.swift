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
  case giftAdded

  // MARK: - Anniversary List
  
  case anniversaryAdded(String)
  case anniversaryModifed(String)
  case anniversaryDeleted(String)
  case anniversaryisPinned(Bool)
  case anniversaryPinLimited
  
  // MARK: - Friend
  
  case tempFriendAdded(String)
  
  // MARK: - Reminder
  
  case reminderAdded
  case reminderDeleted
  case reminderModifed
    
  // MARK: - Network
  
  case networkStatus

  // MARK: - Custom

  case custom(String?)
}

extension ToastMessage {
  public var description: String? {
    switch self {
    case .giftAdded:
      return "선물이 등록되었어요."
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
    case .anniversaryisPinned(let isPinned):
      return isPinned ? "고정 되었습니다." : "고정 해제되었습니다."
      
    case .tempFriendAdded(let friendName):
      return "\(friendName)님이 등록되었습니다."
      
    case .reminderAdded:
      return "리마인더가 등록되었습니다."
    case .reminderDeleted:
      return "리마인더가 삭제되었습니다."
    case .reminderModifed:
      return "리마인더가 수정되었습니다."
      
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
    case .anniversaryPinLimited, .anniversaryisPinned:
      return 94.0
    default:
      return 46.0
    }
  }
}
