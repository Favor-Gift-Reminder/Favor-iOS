//
//  BaseCoordinator.swift
//  Favor
//
//  Created by 이창준 on 2022/12/30.
//

import UIKit

class BaseCoordinator: Coordinator {
	
	// MARK: - Properties
	
  weak var finishDelegate: CoordinatorFinishDelegate?
	var childCoordinators: [any Coordinator]
	var navigationController: UINavigationController
	weak var parentCoordinator: Coordinator?

	// MARK: - Initializer
	
	init(_ navigationController: UINavigationController) {
		self.childCoordinators = []
		self.navigationController = navigationController
	}

	// MARK: - Functions
	
	func start() {
		fatalError("start() method must be implemented.")
	}
	
}
