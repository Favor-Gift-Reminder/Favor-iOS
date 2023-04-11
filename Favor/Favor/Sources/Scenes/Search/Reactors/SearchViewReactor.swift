//
//  SearchViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/02/07.
//

import OSLog

import FavorKit
import ReactorKit
import RxCocoa
import RxFlow

final class SearchViewReactor: Reactor, Stepper {
  
  // MARK: - Properties
  
  var initialState: State
  var steps = PublishRelay<Step>()
  
  enum Action {
    case viewNeedsLoaded
    case backButtonDidTap
    case editingDidBegin
    case textDidChanged(String?)
    case editingDidEnd
    case returnKeyDidTap
  }
  
  enum Mutation {
    case toggleIsEditingTo(Bool)
    case updateText(String?)
  }
  
  struct State {
    var isEditing: Bool = false
    var searchString: String?
  }
  
  // MARK: - Initializer
  
  init() {
    self.initialState = State()
  }
  
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewNeedsLoaded:
      return .just(.toggleIsEditingTo(true))

    case .backButtonDidTap:
      os_log(.debug, "Back Button Did Tap")
      self.steps.accept(AppStep.searchIsComplete)
      return .empty()
      
    case .editingDidBegin:
      return .just(.toggleIsEditingTo(true))

    case .textDidChanged(let text):
      return .just(.updateText(text))
      
    case .editingDidEnd:
      return .just(.toggleIsEditingTo(false))
      
    case .returnKeyDidTap:
      if let searchString = self.currentState.searchString {
        let recentSearch = RecentSearch(searchText: searchString, searchDate: .now)
        _Concurrency.Task {
          try await RealmManager.shared.update(recentSearch)
          self.steps.accept(AppStep.searchResultIsRequired(searchString))
        }
      }
      return .just(.toggleIsEditingTo(false))
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .toggleIsEditingTo(let isEditing):
      newState.isEditing = isEditing

    case .updateText(let text):
      newState.searchString = text
    }
    
    return newState
  }
}
