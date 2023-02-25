//
//  SearchResultViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/02/09.
//

import ReactorKit
import RxCocoa
import RxFlow

final class SearchResultViewReactor: Reactor, Stepper {
  
  // MARK: - Properties
  
  var initialState: State
  var steps = PublishRelay<Step>()
  
  enum Action {
    case backButtonDidTap
  }
  
  enum Mutation {
    
  }
  
  struct State {
    
  }
  
  // MARK: - Initializer
  
  init() {
    self.initialState = State()
  }
  
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .backButtonDidTap:
      print("Back Button Did Tap")
      return .empty()
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
      
    }
    
    return newState
  }
}
