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
    case textDidChanged(String?)
  }
  
  enum Mutation {
    case updateText(String?)
  }
  
  struct State {
    var searchString: String
  }
  
  // MARK: - Initializer
  
  init(initialSearchString: String) {
    self.initialState = State(
      searchString: initialSearchString
    )
  }
  
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .backButtonDidTap:
      self.steps.accept(AppStep.searchResultIsComplete)
      return .empty()

    case .textDidChanged(let text):
      return .just(.updateText(text))
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .updateText(let text):
      newState.searchString = text ?? ""
    }
    
    return newState
  }
}
