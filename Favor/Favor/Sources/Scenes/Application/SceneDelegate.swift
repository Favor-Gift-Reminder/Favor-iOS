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
		let navigationController = UINavigationController()
    
    self.setupNavigationBarAppearance()
		
		self.window = UIWindow(windowScene: windowScene)
		self.window?.rootViewController = navigationController
		self.window?.makeKeyAndVisible()
		
		self.appCoordinator = AppCoordinator(navigationController)
		self.appCoordinator?.start()
	}
}

private extension SceneDelegate {
  func setupNavigationBarAppearance() {
    let appearance = UINavigationBarAppearance()
    let backButtonAppearance = UIBarButtonItemAppearance()
    
    let leftArrowImage = UIImage(named: "ic_leftArrow")?
      .withRenderingMode(.alwaysOriginal)
      .withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0))
    
    backButtonAppearance.normal.titleTextAttributes = [
      .foregroundColor: UIColor.clear
    ]
    
    appearance.setBackIndicatorImage(leftArrowImage, transitionMaskImage: leftArrowImage)
    appearance.backButtonAppearance = backButtonAppearance
    
    appearance.titleTextAttributes = [
      .foregroundColor: UIColor.favorColor(.typo),
      .font: UIFont.favorFont(.bold, size: 18)
    ]
    
    appearance.configureWithTransparentBackground()
    appearance.backgroundColor = .clear
    appearance.shadowColor = nil
        
    UINavigationBar.appearance().compactAppearance = appearance
    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
  }
}
