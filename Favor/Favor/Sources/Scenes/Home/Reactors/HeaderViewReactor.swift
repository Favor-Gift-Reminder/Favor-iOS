//
//  HeaderViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/02/02.
//

import OSLog

import ReactorKit
import RxCocoa

final class HeaderViewReactor: Reactor {
  
  // MARK: - Properties
  
  var initialState: State

  // Global States
  let rightButtonDidTap = PublishRelay<Void>()
  
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
    var sectionType: HomeSectionType
    var selectedButtonIndex: Int = 0
  }
  
  // MARK: - Initializer
  
  init(section: HomeSectionType) {
    self.initialState = State(sectionType: section)
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .allButtonDidTap:
      os_log(.debug, "All button did tap.")
      return .just(.updateSelectedButton(0))
      
    case .getButtonDidTap:
      os_log(.debug, "Get button did tap.")
      return .just(.updateSelectedButton(1))
      
    case .giveButotnDidTap:
      os_log(.debug, "Give button did tap.")
      return .just(.updateSelectedButton(2))
      
    case .rightButtonDidTap:
      os_log(.debug, "Right button did tap.")
      self.rightButtonDidTap.accept(())
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
