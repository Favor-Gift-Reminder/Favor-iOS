//
//  HeaderViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/02/02.
//

import ReactorKit

final class HeaderViewReactor: Reactor {
  
  // MARK: - Properties
  
  var initialState: State
  
  enum Action {
    case allButtonDidTap
    case getButtonDidTap
    case giveButotnDidTap
    case rightButtonDidTap
  }
  
  enum Mutation {
    case updateSelectedButton(Int)
  }
  
  struct State {
    var sectionType: HomeSection
    var selectedButtonIndex: Int = 0
  }
  
  // MARK: - Initializer
  
  init(section: HomeSection) {
    self.initialState = State(sectionType: section)
  }
  
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .allButtonDidTap:
      return .just(.updateSelectedButton(0))
      
    case .getButtonDidTap:
      return .just(.updateSelectedButton(1))
      
    case .giveButotnDidTap:
      return .just(.updateSelectedButton(2))
      
    case .rightButtonDidTap:
      print("Right Button")
      return .empty()
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .updateSelectedButton(let index):
      newState.selectedButtonIndex = index
    }
    
    return newState
  }
}
