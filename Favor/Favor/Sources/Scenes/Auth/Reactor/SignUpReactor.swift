//
//  SignUpReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/01/16.
//

import ReactorKit

final class SignUpReactor: Reactor {
  typealias Action = NoAction
  
  // MARK: - Properties
  
  weak var coordinator: AuthCoordinator?
  var initialState: State
  
  struct State {
    
  }
  
  // MARK: - Initializer
  
  init(coordinator: AuthCoordinator) {
    self.coordinator = coordinator
    self.initialState = State()
  }
  
}
