//
//  SetProfileReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/01/16.
//

import ReactorKit

final class SetProfileReactor: Reactor {
  
  // MARK: - Properties
  
  weak var coordinator: AuthCoordinator?
  var initialState: State
  
  enum Action {
    case ProfileImageButtonTap
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
    case .ProfileImageButtonTap:
      self.coordinator?.presentImagePicker()
      return Observable<Mutation>.empty()
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
      
    }
    
    return newState
  }
  
}
