//
//  UIApplication+.swift
//
//
//  Created by 김응철 on 7/3/23.
//

import UIKit

import RxSwift
import RxCocoa

extension UIApplication {
  /// 최상단 ViewController를 참조할 수 있게 도와주는 메서드입니다.
  public func topViewController(
    _ base: UIViewController? = (
      UIApplication.shared.connectedScenes.first as? UIWindowScene
    )?.windows.first?.rootViewController
  ) -> UIViewController? {
    if let nav = base as? UINavigationController {
      return topViewController(nav.visibleViewController)
    }
    
    if let tab = base as? UITabBarController {
      if let selected = tab.selectedViewController {
        return topViewController(selected)
      }
    }
    
    if let presented = base?.presentedViewController {
      return topViewController(presented)
    }
    
    return base
  }
  
  public func topViewControllerAsObservable() -> Observable<UIViewController?> {
    return Observable.create { observer in
      DispatchQueue.main.async {
        let topViewController = UIApplication.shared.topViewController()
        observer.onNext(topViewController)
        observer.onCompleted()
      }
      return Disposables.create()
    }
  }
}
