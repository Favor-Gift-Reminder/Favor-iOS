//
//  SceneDelegate.swift
//  Favor
//
//  Created by 이창준 on 2022/12/29.
//

import UIKit

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
    
    self.coordinator.rx.didNavigate.subscribe(onNext: { flow, step in
      print("Navigate to flow - \(flow) and step - \(step)")
    }).disposed(by: self.disposeBag)
    
    let appFlow = AppFlow(with: window)
    
    self.coordinator.coordinate(flow: appFlow, with: AppStepper())
    window.makeKeyAndVisible()
	}
}
