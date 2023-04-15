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

public enum SearchViewMode {
  case search, result
}

final class SearchViewReactor: Reactor, Stepper {

  // MARK: - Constants

  public enum SearchType {
    case gift, user
  }

  // MARK: - Properties
  
  var initialState: State
  var steps = PublishRelay<Step>()
  let mode: SearchViewMode
  
  enum Action {
    case viewNeedsLoaded
    case editingDidBegin
    case textDidChanged(String?)
    case editingDidEnd
    case returnKeyDidTap
    case searchRecentDidSelected(SearchRecentSection.SearchRecentItem)
    case searchTypeDidSelected(SearchType)
    case viewWillDisappear
  }
  
  enum Mutation {
    case toggleIsEditingTo(Bool)
    case updateText(String?)
    case updateRecentSearches(SearchRecentSection.SearchRecentModel)
    case updateSearchType(SearchType)
  }
  
  struct State {
    var isEditing: Bool = false
    var searchQuery: String?
    var searchRecents = SearchRecentSection.SearchRecentModel(
      model: .zero,
      items: []
    )
    var selectedSearchType: SearchType = .gift
    var giftResults = SearchResultSection.SearchGiftResultModel(
      model: .gift,
      items: [.gift(SearchGiftResultCellReactor()), .gift(SearchGiftResultCellReactor()), .gift(SearchGiftResultCellReactor()), .gift(SearchGiftResultCellReactor()), .gift(SearchGiftResultCellReactor()), .gift(SearchGiftResultCellReactor()), .gift(SearchGiftResultCellReactor()), .gift(SearchGiftResultCellReactor()), .gift(SearchGiftResultCellReactor())]
    )
    var userResult = SearchResultSection.SearchGiftResultModel(
      model: .user,
      items: [.user(SearchUserResultCellReactor())]
    )
  }
  
  // MARK: - Initializer
  
  init(mode: SearchViewMode, searchQuery: String? = nil) {
    self.initialState = State(
      searchQuery: searchQuery
    )
    self.mode = mode
  }

  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewNeedsLoaded:
      return self.createSearchRecents()
        .asObservable()
        .flatMap { searchRecents -> Observable<Mutation> in
          let model = self.refineRecentSearch(searchRecents: searchRecents)
          return .concat([
            .just(.updateRecentSearches(model)),
            .just(.toggleIsEditingTo(true))
          ])
        }

    case .viewWillDisappear:
      switch self.mode {
      case .search:
        self.steps.accept(AppStep.searchIsComplete)
      case .result:
        self.steps.accept(AppStep.searchResultIsComplete)
      }
      return .empty()
      
    case .editingDidBegin:
      return .just(.toggleIsEditingTo(true))

    case .textDidChanged(let text):
      return .just(.updateText(text))
      
    case .editingDidEnd:
      return .just(.toggleIsEditingTo(false))
      
    case .returnKeyDidTap:
      if let searchString = self.currentState.searchQuery {
        switch self.mode {
        case .search:
          self.updateAndNavigateToSearchResult(searchString)
        case .result:
          return .concat([
            .just(.toggleIsEditingTo(false)),
            .empty() // TODO: Update Result
          ])
        }
      }
      return .just(.toggleIsEditingTo(false))

    case .searchRecentDidSelected(let item):
      switch item {
      case .recent(let recentSearchString):
        self.updateAndNavigateToSearchResult(recentSearchString)
      }
      return .empty()

    case .searchTypeDidSelected(let searchType):
      return .just(.updateSearchType(searchType))
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .toggleIsEditingTo(let isEditing):
      newState.isEditing = isEditing

    case .updateText(let text):
      newState.searchQuery = text

    case .updateRecentSearches(let recentSearches):
      newState.searchRecents = recentSearches

    case .updateSearchType(let searchType):
      newState.selectedSearchType = searchType
    }
    
    return newState
  }
}

// MARK: - Privates

private extension SearchViewReactor {
  func refineRecentSearch(searchRecents: [SearchRecent]) -> SearchRecentSection.SearchRecentModel {
    let sortedRecentSearches = searchRecents.sorted(by: { $0.searchDate > $1.searchDate })
    let recentSearchItems = sortedRecentSearches.map {
      let searchText = $0.searchText
      return SearchRecentSection.SearchRecentItem.recent(searchText)
    }
    return SearchRecentSection.SearchRecentModel(
      model: .zero,
      items: recentSearchItems
    )
  }

  func createSearchRecents() -> Single<[SearchRecent]> {
    return Single<[SearchRecent]>.create { single in
      let task = Task {
        do {
          let searches = try await RealmManager.shared.read(SearchRecent.self).toArray()
          single(.success(searches))
        } catch {
          single(.failure(error))
        }
      }

      return Disposables.create {
        task.cancel()
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
