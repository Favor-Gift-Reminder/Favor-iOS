//
//  AppDelegate.swift
//  Favor
//
//  Created by 이창준 on 2022/12/29.
//

import UIKit

import FavorKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.

    // FavorKit Package의 Custom Font Register 메서드
    FavorKit.registerFonts()

    RealmWorkbench().locateRealm()

    #if DEBUG
//    FTUXStorage.isSignedIn = true
//    UserInfoStorage.userNo = 26
    #endif
    print("Current User: \(UserInfoStorage.userNo)")
    
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
