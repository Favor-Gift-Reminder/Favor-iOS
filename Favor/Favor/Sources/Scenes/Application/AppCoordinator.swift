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
		// TODO: - Onboard 구현 후 분기 처리
		let homeCoordinator = HomeCoordinator(self.navigationController)
		self.start(childCoordinator: homeCoordinator)
	}
	
}
