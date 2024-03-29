//
//  AppDelegate.swift
//  Favor
//
//  Created by 이창준 on 2022/12/29.
//

import UIKit

import FavorKit
import KakaoSDKAuth
import RxKakaoSDKAuth
import RxKakaoSDKCommon

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.

    // FavorKit Package의 Custom Font Register 메서드
    FavorKit.registerFonts()
    
    // RealmDB의 파일 위치 출력
    RealmWorkbench().locateRealm()
    // KakaoSDK 초기화
    RxKakaoSDK.initSDK(appKey: "${NATIVE_APP_KEY}")
    
    // 네트워크 모니터링 시작
    NetworkCheckManager.shared.startMonitoring()
    
    // 로컬 푸쉬 알림
    UNUserNotificationCenter.current().delegate = self
    let authOptions: UNAuthorizationOptions = [.alert, .carPlay, .sound]
    UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
    
    #if DEBUG
    UserInfoStorage.userNo = 1
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

  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    // 카카오톡 인증을 마치고 앱으로 돌아왔을 때의 처리 설정
    if AuthApi.isKakaoTalkLoginUrl(url) {
      return AuthController.rx.handleOpenUrl(url: url)
    }

    return false
  }
}

// 로컬 알림

extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void) {
      completionHandler()
  }
  
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent noti: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.list, .sound, .badge, .banner])
  }
}
