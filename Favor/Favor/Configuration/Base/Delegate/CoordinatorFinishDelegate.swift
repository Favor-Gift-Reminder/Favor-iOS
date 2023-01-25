//
//  CoordinatorFinishDelegate.swift
//  Favor
//
//  Created by 이창준 on 2023/01/25.
//

protocol CoordinatorFinishDelegate: AnyObject {
  func coordinatorDidFinish(childCoordinator: some Coordinator)
}
