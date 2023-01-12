//
//  SelectSignInReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/01/11.
//

import Foundation

import ReactorKit

final class SelectSignInReactor: Reactor {
  
  // MARK: - Properties
  
  weak var coordinator: AuthCoordinator?
  var initialState: State
  
  enum Action {
    case idLoginButtonTap
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
    case .idLoginButtonTap:
      self.coordinator?.showSignInFlow()
      return Observable<Mutation>.empty()
    }
  }
  
}
