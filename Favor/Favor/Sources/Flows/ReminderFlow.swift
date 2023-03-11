//
//  ReminderFlow.swift
//  Favor
//
//  Created by 이창준 on 2023/03/11.
//

import UIKit

import FavorKit
import RxFlow

final class ReminderFlow: Flow {

  var root: Presentable { self.rootViewController }

  let rootViewController = BaseNavigationController()

  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    default: return .none
    }
  }
}
