//
//  AppCoordinator.swift
//  Favor
//
//  Created by 이창준 on 2022/12/30.
//

import UIKit

final class AppCoordinator: Coordinator {
	
	// MARK: - Properties
	
	var navigationController: UINavigationController
	var childCoordinators: [Coordinator]
	var parentCoordinator: Coordinator?
	
	// MARK: - Initializer
	
	init(_ navigationController: UINavigationController) {
		self.childCoordinators = []
		self.navigationController = navigationController
	}
	
	// MARK: - Functions
	
	func start() {
		self.showHomeFlow()
	}
	
}

private extension AppCoordinator {
	
	/// Home 화면을 push합니다.
	func showHomeFlow() {
		// TODO: Home 화면 구현 후 pushNavigationController 구현
	}
	
}
