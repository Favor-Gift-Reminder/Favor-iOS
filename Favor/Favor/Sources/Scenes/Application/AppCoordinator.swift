//
//  AppCoordinator.swift
//  Favor
//
//  Created by 이창준 on 2022/12/30.
//

import UIKit

final class AppCoordinator: BaseCoordinator {
	
	// MARK: - Properties
	
	// MARK: - Initializer
	
	// MARK: - Functions
	
	override func start() {
    self.showSplashFlow()
	}
	
}

extension AppCoordinator {
  
  /// 앱에 필요한 데이터들을 pre-fetch하기 위해 출력되는 View입니다.
  func showSplashFlow() {
    let splashViewController = SplashViewController()
    self.navigationController.setNavigationBarHidden(true, animated: false)
    self.navigationController.pushViewController(splashViewController, animated: false)
  }
}
