//
//  SplashReactor.swift
//  Favor
//
//  Created by 이창준 on 2022/12/31.
//

import ReactorKit

final class SplashReactor: Reactor {
  
  // MARK: - Properties
  
  weak var coordinator: AppCoordinator?
  var initialState: State
  
  typealias Action = NoAction
  
  enum Mutation {
    case prefetch
  }
  
  struct State {
    var isPrefetchDone: Bool
  }
  
  // MARK: - Initializer
  
  init(coordinator: AppCoordinator) {
    self.coordinator = coordinator
    self.initialState = State(
      isPrefetchDone: false
    )
  }
  
  // MARK: - Functions
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case .prefetch:
      // TODO: - Prefetch 로직 구현
      // if success
      newState.isPrefetchDone = true
    }
    return newState
  }
}
