//
//  FavorNotificationManager.swift
//
//
//  Created by 김응철 on 7/3/23.
//

import UIKit

/// 팝업이나 토스트 메세지를 외부에서 관리할 수 있는 매니저입니다.
///
/// 사용자에게 단방향 메세지를 전달하기 위한 용도입니다.
///
/// 주로 네트워크 오류가 발생했을 때 어떤 오류인지 사용자가 알 수 있도록 합니다.
final public class FavorNotificationManager {
  
  // MARK: - Properties
  
  /// `FavorPopupManager`는 싱글톤 객체입니다.
  static public let shared = FavorNotificationManager()
  
  // MARK: - Functions
  
  /// 최 상단 ViewController에 팝업을 팝업을 띄웁니다.
  /// - Parameters:
  ///  - message: 사용자에게 알릴 메세지 `String`
  public func showFavorPopup(_ message: String) {
    let favorPopup = FavorPopup(message)
    favorPopup.modalPresentationStyle = .overFullScreen
    UIApplication.shared.topViewController()?.present(favorPopup, animated: false)
  }
}
