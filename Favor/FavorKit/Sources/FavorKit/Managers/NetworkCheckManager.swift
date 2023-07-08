//
//  NetworkCheckManager.swift
//
//
//  Created by 김응철 on 7/3/23.
//

import UIKit
import Network
import OSLog

/// 현재 인터넷 연결 상태를 알 수 있는 매니저 객체입니다.
///
/// 이 객체는 싱글톤 디자인으로 구현되어 있습니다.
final public class NetworkCheckManager {
  
  // MARK: - Properties
  
  /// SingleTon
  static public let shared = NetworkCheckManager()
  
  /// 현재 인터넷 연결상태를 나타냅니다.
  ///
  /// 네트워크 연결 상태가 좋지 못 하면 ToastMessage를 띄웁니다.
  public var isConnected: Bool = false {
    willSet {
      DispatchQueue.main.async {
        if newValue {
          // 인터넷 연결 됐을 때
          ToastManager.shared.resetToast()
        } else {
          // 인터넷 연결이 끊겼을 때
          guard let topViewController = UIApplication.shared.topViewController() as? BaseViewController
          else { return }
          ToastManager.shared.showNewToast(
            FavorToastMessageView(.networkStatus),
            at: topViewController,
            duration: .long
          )
        }
      }
    }
  }
  
  /// 인터넷 연결 상태를 체크해주는 모니터입니다.
  private let monitor = NWPathMonitor()
  
  // MARK: - Functions
  
  /// 네트워크 상태 모니터링을 시작합니다.
  ///
  /// Handler를 통해서 네트워크 상태가 바뀌면 다양한 액션을 취할 수 있습니다.
  public func startMonitoring() {
    self.monitor.start(queue: DispatchQueue.global())
    
    self.monitor.pathUpdateHandler = { [weak self] path in
      guard let self else { return }
      // 네트워크 상태를 확인하여 isConnected를 업데이트합니다.
      self.isConnected = !(path.status == .unsatisfied)
      os_log(.info, "🛜 네트워크 상태 변경: \(self.isConnected)")
    }
  }
}
