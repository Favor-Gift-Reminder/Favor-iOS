//
//  SceneDelegate.swift
//  Favor
//
//  Created by 이창준 on 2022/12/29.
//

import OSLog
import UIKit

import FavorKit
import RxFlow
import RxSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?
  var coordinator = FlowCoordinator()
  let disposeBag = DisposeBag()

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = (scene as? UIWindowScene) else { return }
    
    let window = UIWindow(windowScene: windowScene)
    self.window = window

    self.enableNavigateLog()
    
    let appFlow = AppFlow()
    self.coordinator.coordinate(flow: appFlow, with: OneStepper(withSingleStep: AppStep.splashIsRequired))

    Flows.use(appFlow, when: .created) { root in
      window.rootViewController = root
      window.makeKeyAndVisible()
    }
	}
}

private extension SceneDelegate {
  func enableNavigateLog() {
    self.coordinator.rx.didNavigate.subscribe(onNext: { flow, step in
      let message = "➡️ Navigate to flow = \(flow) and step = \(step)"
      os_log(.debug, "\(message)")
    }).disposed(by: self.disposeBag)
  }
}
