//
//  SignInReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/01/12.
//

import OSLog

import ReactorKit

final class SignInReactor: Reactor {
  
  // MARK: - Properties
  
  let coordinator: AuthCoordinator
  var initialState: State
  
  enum Action {
    case loginButtonTap
    case returnKeyboardTap
  }
  
  enum Mutation {
    
  }
  
  struct State {
    
  }
  
  // MARK: - Initializer
  
  init(coordinator: AuthCoordinator) {
    self.coordinator = coordinator
    self.initialState = State()
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .loginButtonTap, .returnKeyboardTap:
      os_log(.error, "Login logic should be implemented.")
      return Observable<Mutation>.empty()
    }
  }
  
}
