//
//  SelectSignInReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/01/11.
//

import OSLog

import ReactorKit

final class SelectSignInReactor: Reactor {
  
  // MARK: - Properties
  
  let coordinator: AuthCoordinator
  var initialState: State
  
  enum Action {
    case emailLoginButtonTap
    case signUpButtonTap
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
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .emailLoginButtonTap:
      self.coordinator.showSignInFlow()
      return Observable<Mutation>.empty()
    case .signUpButtonTap:
      self.coordinator.showSignUpFlow()
      return Observable<Mutation>.empty()
    }
  }
  
}
