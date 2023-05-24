//
//  Toastable.swift
//  Favor
//
//  Created by 이창준 on 2023/05/22.
//

import UIKit

public protocol Toastable: UIViewController {

  var toast: FavorToastMessageView? { get set }

  func viewNeedsLoaded(with toast: ToastMessage?)
}

extension Toastable {
  public func presentToast(_ message: ToastMessage?, duration: ToastManager.duration) {
    guard let toastMessage = message?.description else { return }
    self.toast = ToastManager.shared.prepareToast(toastMessage)
    guard let toast = self.toast else { return }
    ToastManager.shared.showNewToast(toast, at: self)
  }

  public func dismissToast() {
    guard let toast = self.toast else { return }
    ToastManager.shared.hideToast(toast, from: self)
  }
}
