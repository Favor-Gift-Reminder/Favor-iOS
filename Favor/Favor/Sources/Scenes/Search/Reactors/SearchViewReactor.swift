//
//  SearchViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/02/07.
//

import OSLog

import FavorKit
import ReactorKit
import RealmSwift
import RxCocoa
import RxFlow

final class SearchViewReactor: Reactor, Stepper {
  
  // MARK: - Properties
  
  var initialState: State
  var steps = PublishRelay<Step>()

  // Global State
  let searchRecents = PublishRelay<[SearchRecent]>()
  
  enum Action {
    case viewNeedsLoaded
    case backButtonDidTap
    case editingDidBegin
    case textDidChanged(String?)
    case editingDidEnd
    case returnKeyDidTap
    case searchRecentDidSelected(SearchRecentSection.SearchRecentItem)
  }
  
  enum Mutation {
    case toggleIsEditingTo(Bool)
    case updateText(String?)
    case updateRecentSearches(SearchRecentSection.SearchRecentModel)
  }
  
  struct State {
    var isEditing: Bool = false
    var searchString: String?
    var searchRecents = SearchRecentSection.SearchRecentModel(
      model: .zero,
      items: []
    )
  }
  
  // MARK: - Initializer
  
  init() {
    self.initialState = State()
  }

  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewNeedsLoaded:
      self.fetchSearchRecents()
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
        self.updateAndNavigateToSearchResult(searchString)
      }
      return .just(.toggleIsEditingTo(false))

    case .searchRecentDidSelected(let item):
      switch item {
      case .recent(let recentSearchString):
        self.updateAndNavigateToSearchResult(recentSearchString)
      }
      return .empty()
    }
  }

  func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
    let searchRecents = self.searchRecents.flatMap { searchRecents -> Observable<Mutation> in
      let searchRecentModel = self.refineRecentSearch(recentSearches: searchRecents)
      return .just(.updateRecentSearches(searchRecentModel))
    }
    return .merge(
      mutation,
      searchRecents
    )
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .toggleIsEditingTo(let isEditing):
      newState.isEditing = isEditing

    case .updateText(let text):
      newState.searchString = text

    case .updateRecentSearches(let recentSearches):
      newState.searchRecents = recentSearches
    }
    
    return newState
  }
}

// MARK: - Privates

private extension SearchViewReactor {
  func refineRecentSearch(recentSearches: [SearchRecent]) -> SearchRecentSection.SearchRecentModel {
    let sortedRecentSearches = recentSearches.sorted(by: { $0.searchDate > $1.searchDate })
    let recentSearchItems = sortedRecentSearches.map {
      let searchText = $0.searchText
      return SearchRecentSection.SearchRecentItem.recent(searchText)
    }
    return SearchRecentSection.SearchRecentModel(
      model: .zero,
      items: recentSearchItems
    )
  }

  func fetchSearchRecents() {
    Task {
      do {
        let searches = try await RealmManager.shared.read(SearchRecent.self).toArray()
        self.searchRecents.accept(searches)
      } catch {
        self.searchRecents.accept([])
      }
    }
  }

  func updateAndNavigateToSearchResult(_ searchString: String) {
    let searchRecent = SearchRecent(searchText: searchString, searchDate: .now)
    _Concurrency.Task {
      try await RealmManager.shared.update(searchRecent)
      self.steps.accept(AppStep.searchResultIsRequired(searchString))
    }
  }
}
