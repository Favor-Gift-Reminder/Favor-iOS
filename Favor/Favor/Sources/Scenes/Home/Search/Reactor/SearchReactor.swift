//
//  SearchReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/02/07.
//

import ReactorKit
import RxCocoa
import RxFlow

final class SearchReactor: Reactor, Stepper {
  
  // MARK: - Properties
  
  var initialState: State
  var steps = PublishRelay<Step>()
  
  enum Action {
    case backButtonDidTap
    case searchDidBegin
    case searchDidEnd
  }
  
  enum Mutation {
    case switchIsEditingTo(Bool)
  }
  
  struct State {
    var isEditing: Bool = false
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
      
    case .searchDidBegin:
      return .just(.switchIsEditingTo(true))
      
    case .searchDidEnd:
      return .just(.switchIsEditingTo(false))
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .switchIsEditingTo(let isEditing):
      newState.isEditing = isEditing
    }
    
    return newState
  }
}
