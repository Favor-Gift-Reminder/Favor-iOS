//
//  AuthFlow.swift
//  Favor
//
//  Created by 이창준 on 2023/01/27.
//

import UIKit

import RxCocoa
import RxFlow
import RxSwift

final class AuthFlow: Flow {
  
  var root: Presentable { self.rootViewController }
  
  let rootViewController = SelectSignInViewController()
  
  func navigate(to step: Step) -> FlowContributors {
    return .none
  }
  
}
