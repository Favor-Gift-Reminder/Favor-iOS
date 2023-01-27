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
//    self.showOnboardFlow()
    self.showAuthFlow()
//    self.showTabBarFlow()
	}
  
  override func finish(childCoordinator: some Coordinator) {
    super.finish(childCoordinator: childCoordinator)
    
    self.navigationController.viewControllers.removeAll()
    
    switch childCoordinator.self {
    case is AuthCoordinator:
      self.showTabBarFlow()
    case is TabBarCoordinator:
      self.showAuthFlow()
    default:
      break
    }
  }
  
}

extension AppCoordinator {
  
  /// 앱에 필요한 데이터들을 pre-fetch하기 위해 출력되는 View입니다.
  func showSplashFlow() {
    let splashViewController = SplashViewController()
    self.navigationController.setNavigationBarHidden(true, animated: false)
    self.navigationController.pushViewController(splashViewController, animated: false)
  }
  
  /// Main Scene에 진입 시에 하단에 깔리는 TabBar를 담당하는 View입니다.
  func showTabBarFlow() {
    let tabBarCoordinator = TabBarCoordinator(self.navigationController)
    self.start(childCoordinator: tabBarCoordinator)
  }
  
  /// 첫 실행 시 온보딩 화면을 출력하는 View입니다.
  func showOnboardFlow() {
    let onboardingVC = OnboardingViewController()
    self.navigationController.setNavigationBarHidden(true, animated: false)
    self.navigationController.pushViewController(onboardingVC, animated: true)
  }
  
  /// 로그인 / 회원가입 로직을 처리하는 View입니다. 최초 실행 시 온보딩 view에서 접근됩니다.
  func showAuthFlow() {
    let authCoordinator = AuthCoordinator(self.navigationController)
    self.start(childCoordinator: authCoordinator)
  }
}
