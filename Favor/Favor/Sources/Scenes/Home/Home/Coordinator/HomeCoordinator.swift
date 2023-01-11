//
//  HomeCoordinator.swift
//  Favor
//
//  Created by 이창준 on 2022/12/30.
//

import UIKit

final class HomeCoordinator: BaseCoordinator {
	
	// MARK: - Properties
	
	// MARK: - Initializer
	
	// MARK: - Functions
	
	override func start() {
		let homeReactor = HomeReactor(coordinator: self)
		let homeViewController = HomeViewController()
    homeViewController.reactor = homeReactor
		self.navigationController.pushViewController(homeViewController, animated: true)
	}
	
}
