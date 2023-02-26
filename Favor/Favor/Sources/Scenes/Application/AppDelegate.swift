//
//  AppDelegate.swift
//  Favor
//
//  Created by 이창준 on 2022/12/29.
//

import UIKit

import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
    
    self.setupNavigationBarAppearance()

    let realm = try! Realm()
    print("Realm is located at:", realm.configuration.fileURL!)
    
		return true
	}

	// MARK: UISceneSession Lifecycle

	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		// Called when a new scene session is being created.
		// Use this method to select a configuration to create the new scene with.
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}

	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
			// Called when the user discards a scene session.
			// If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
			// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
	}

}

private extension AppDelegate {
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
      .foregroundColor: UIColor.favorColor(.titleAndLine),
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
