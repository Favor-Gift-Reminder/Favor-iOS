//
//  Coordinator.swift
//  Favor
//
//  Created by 김응철 on 2022/12/29.
//

import UIKit

protocol Coordinator: AnyObject {

  var navigationController: UINavigationController { get set }
  var childCoordinators: [any Coordinator] { get set }
  var parentCoordinator: Coordinator? { get set }
  
  func start()
  func start(childCoordinator: some Coordinator)
  func finish()
  func finish(childCoordinator: some Coordinator)
}

extension Coordinator {
  func start(childCoordinator: some Coordinator) {
    self.childCoordinators.append(childCoordinator)
    childCoordinator.parentCoordinator = self
    childCoordinator.start()
  }
}
