//
//  SceneDelegate.swift
//  Favor
//
//  Created by 이창준 on 2022/12/29.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?
	var appCoordinator: AppCoordinator?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = (scene as? UIWindowScene) else { return }
		let navigationController = BaseNavigationController()
		
		self.window = UIWindow(windowScene: windowScene)
		self.window?.rootViewController = navigationController
		self.window?.makeKeyAndVisible()
		
		self.appCoordinator = AppCoordinator(navigationController)
		self.appCoordinator?.start()
	}
}
