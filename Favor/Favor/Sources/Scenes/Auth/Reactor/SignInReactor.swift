//
//  SignInReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/01/12.
//

import ReactorKit

final class SignInReactor: Reactor {
  
  // MARK: - Properties
  
  let coordinator: AuthCoordinator
  var initialState: State
  
  enum Action {
    
  }
  
  struct State {
    
  }
  
  // MARK: - Initializer
  
  init(coordinator: AuthCoordinator) {
    self.coordinator = coordinator
    self.initialState = State()
  }
  
}
