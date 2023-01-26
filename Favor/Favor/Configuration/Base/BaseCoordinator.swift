//
//  BaseCoordinator.swift
//  Favor
//
//  Created by 이창준 on 2022/12/30.
//

import UIKit

class BaseCoordinator: Coordinator {
	
	// MARK: - Properties
	
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
  
  func finish() {
    self.parentCoordinator?.finish(childCoordinator: self)
  }
  
  /// Child Coordinator들의 컬렉션에서 인자로 받는 코디네이터를 제거합니다.
  func finish(childCoordinator: some Coordinator) {
    childCoordinators = childCoordinators.filter { $0 !== childCoordinator }
  }
}
