//
//  ToastManager.swift
//  Favor
//
//  Created by 이창준 on 2023/03/14.
//

import UIKit
import OSLog

import SnapKit

public final class ToastManager {

  // MARK: - Constants
  
  public enum Duration {
    case short, long, forever

    var timeInterval: TimeInterval {
      switch self {
      case .short: return 1.0
      case .long: return 3.0
      case .forever: return 180.0
      }
    }
  }
  
  // MARK: - Properties

  public static let shared = ToastManager()

  public var popInDuration: TimeInterval = 0.2
  public var popOutDuration: TimeInterval = 0.3

  private var queue = Queue<FavorToastMessageView>()

  // MARK: - Initializer

  private init() { }

  // MARK: - Functions
  
  /// `FavorToastMessageView` 객체를 생성합니다.
  public func prepareToast(_ message: ToastMessage) -> FavorToastMessageView {
    let toast = FavorToastMessageView(message)
    return toast
  }
  
  /// ToastView를 최상단 VC 위에 띄웁니다.
  public func showNewToast(
    _ toast: FavorToastMessageView,
    duration: ToastManager.Duration = .short,
    completion: (() -> Void)? = nil
  ) {
    toast.duration = duration
    self.queue.enqueue(toast)
    
    guard let topViewController = UIApplication.shared.topViewController() else {
      os_log(.error, "뷰컨트롤러를 참조되지 못했습니다.")
      return
    }
    
    if self.queue.peek() === toast { // Queue에 쌓인 토스트가 없을 경우 (현재 토스트가 present 될 수 있을 경우)
      self.showToast(
        toast,
        at: topViewController,
        completion: completion
      )
    } else { // Queue에 쌓인 토스트가 있을 경우
      return
    }
  }
  
  public func hideToast(
    _ toast: FavorToastMessageView,
    from viewController: UIViewController,
    duration: ToastManager.Duration? = nil
  ) {
    let animator = UIViewPropertyAnimator(duration: self.popOutDuration, curve: .easeInOut) {
      toast.alpha = 0.0
      toast.snp.updateConstraints { make in
        make.bottom.equalTo(viewController.view.safeAreaLayoutGuide)
      }
      viewController.view.layoutIfNeeded()
    }
    animator.addCompletion { _ in
      DispatchQueue.main.asyncAfter(deadline: .now() + self.popOutDuration) {
        toast.removeFromSuperview()
        
        self.queue.dequeue()
        if let nextToast = self.queue.peek() {
          self.showToast(nextToast, at: viewController)
        }
      }
    }
    if let duration {
      animator.startAnimation(afterDelay: duration.timeInterval)
    } else {
      animator.startAnimation()
    }
  }

  public func resetToast() {
    self.queue = Queue<FavorToastMessageView>()
  }
  
  // MARK: - Privates
  
  private func showToast(
    _ toast: FavorToastMessageView,
    at viewController: UIViewController,
    completion: (() -> Void)? = nil
  ) {
    toast.alpha = 0.0
    viewController.view.addSubview(toast)
    
    toast.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(viewController.view.safeAreaLayoutGuide)
      make.directionalHorizontalEdges.equalTo(viewController.view.layoutMarginsGuide).inset(20)
      make.height.equalTo(44.0)
    }
    viewController.view.layoutIfNeeded()
    
    let animator = UIViewPropertyAnimator(duration: self.popInDuration, curve: .easeInOut) {
      toast.alpha = 1.0
      toast.snp.updateConstraints { make in
        make.bottom.equalTo(viewController.view.safeAreaLayoutGuide).inset(toast.message?.bottomInset ?? 0.0)
      }
      viewController.view.layoutIfNeeded()
    }
    animator.addCompletion { _ in
      self.hideToast(toast, from: viewController, duration: toast.duration)
      if let completion { completion() }
    }
    animator.startAnimation()
  }
}
