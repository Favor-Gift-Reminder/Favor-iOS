//
//  Coordinator.swift
//  Favor
//
//  Created by 김응철 on 2022/12/29.
//

import UIKit

protocol Coordinator: AnyObject {

  var finishDelegate: CoordinatorFinishDelegate? { get set }
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
  
  /// 해당 Coordinator의 모든 Child들을 할당 해제한 뒤에 해당 Coordinator 또한 해제합니다.
  /// 해당 Coordinator 해제는 delegate 패턴을 사용하여 이루어집니다.
  func finish() {
    self.childCoordinators.removeAll()
    self.finishDelegate?.coordinatorDidFinish(childCoordinator: self)
  }

  func finish(childCoordinator: some Coordinator) {
    childCoordinators = childCoordinators.filter { $0 !== childCoordinator }
  }
}
