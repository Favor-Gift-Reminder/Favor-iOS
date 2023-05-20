//
//  FriendManagementViewReactor.swift
//  Favor
//
//  Created by 김응철 on 2023/05/19.
//

import ReactorKit
import RxFlow
import RxCocoa

final class FriendManagementViewReactor: Reactor, Stepper {
  
  typealias Action = NoAction
  
  struct State {
    
  }
  
  // MARK: - Properties
  
  var steps = PublishRelay<Step>()
  var initialState: State = State()
}
