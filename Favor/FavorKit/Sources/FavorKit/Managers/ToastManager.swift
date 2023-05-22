//
//  ToastManager.swift
//  Favor
//
//  Created by 이창준 on 2023/03/14.
//

import UIKit

import SnapKit

public final class ToastManager {

  // MARK: - Constants

  public enum duration {
    case short, long, forever

    var timeInterval: TimeInterval {
      switch self {
      case .short: return 3.0
      case .long: return 5.0
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
  public func prepareToast(_ message: String) -> FavorToastMessageView {
    let toast = FavorToastMessageView(message)
    return toast
  }

  private func showToast(
    _ toast: FavorToastMessageView,
    at viewController: Toastable,
    completion: (() -> Void)? = nil
  ) {
    toast.alpha = 0.0
    viewController.view.addSubview(toast)

    toast.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(viewController.view.safeAreaLayoutGuide)
      make.directionalHorizontalEdges.equalTo(viewController.view.layoutMarginsGuide).inset(20)
    }
    viewController.view.layoutIfNeeded()

    let animator = UIViewPropertyAnimator(duration: self.popInDuration, curve: .easeInOut) {
      toast.alpha = 1.0
      toast.snp.updateConstraints { make in
        make.bottom.equalTo(viewController.view.safeAreaLayoutGuide).inset(20)
      }
      viewController.view.layoutIfNeeded()
    }
    animator.addCompletion { _ in
      self.hideToast(toast, from: viewController, duration: toast.duration)
      if let completion { completion() }
    }
    animator.startAnimation()
  }

  /// ToastView를 최상단 VC 위에 띄웁니다.
  public func showNewToast(
    _ toast: FavorToastMessageView,
    at viewController: Toastable,
    duration: ToastManager.duration = .short,
    completion: (() -> Void)? = nil
  ) {
    toast.duration = duration
    self.queue.enqueue(toast)

    if self.queue.peek() === toast { // Queue에 쌓인 토스트가 없을 경우 (현재 토스트가 present 될 수 있을 경우)
      self.showToast(
        toast,
        at: viewController,
        completion: completion
      )
    } else { // Queue에 쌓인 토스트가 있을 경우
      return
    }
  }

  public func hideToast(
    _ toast: FavorToastMessageView,
    from viewController: Toastable,
    duration: ToastManager.duration? = nil
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
}
