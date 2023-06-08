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
  private let workbench = try! RealmWorkbench()
  private let mode: SearchViewMode

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
      items: [
        .gift(SearchGiftResultCellReactor()),
        .gift(SearchGiftResultCellReactor()),
        .gift(SearchGiftResultCellReactor()),
        .gift(SearchGiftResultCellReactor()),
        .gift(SearchGiftResultCellReactor()),
        .gift(SearchGiftResultCellReactor()),
        .gift(SearchGiftResultCellReactor()),
        .gift(SearchGiftResultCellReactor()),
        .gift(SearchGiftResultCellReactor())
      ]
    )
    var userResult = SearchResultSection.SearchGiftResultModel(
      model: .user,
      items: [
//        .user(SearchUserResultCellReactor())
      ]
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
      switch self.mode {
      case .search:
        return self.createSearchRecents()
          .flatMap { searchRecents -> Observable<Mutation> in
            let model = self.refineRecentSearch(searchRecents: searchRecents)
            return .concat([
              .just(.updateRecentSearches(model)),
              .just(.toggleIsEditingTo(true))
            ])
          }
      case .result:
        return .just(.updateSearchType(.gift))
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

  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      // Upcoming이 비어있을 경우 .empty 데이터 추가
      if state.giftResults.items.isEmpty {
        newState.giftResults.items.append(.empty(nil, "검색 결과가 없습니다."))
      }
      // Timeline이 비어있을 경우 .empty 데이터 추가
      if state.userResult.items.isEmpty {
        newState.userResult.items.append(.empty(nil, "검색 결과가 없습니다."))
      }
      return newState
    }
  }
}

// MARK: - Privates

private extension SearchViewReactor {
  func refineRecentSearch(searchRecents: [RecentSearch]) -> SearchRecentSection.SearchRecentModel {
    let sortedRecentSearches = searchRecents.sorted(by: { $0.date > $1.date })
    let recentSearchItems = sortedRecentSearches.map {
      let query = $0.query
      return SearchRecentSection.SearchRecentItem.recent(query)
    }
    return SearchRecentSection.SearchRecentModel(
      model: .zero,
      items: recentSearchItems
    )
  }

  func createSearchRecents() -> Observable<[RecentSearch]> {
    return Observable<[RecentSearch]>.create { observer in
      let task = Task {
        let searches = await self.workbench.values(RecentSearchObject.self)
          .map { RecentSearch(realmObject: $0) }
        observer.onNext(Array(searches))
        observer.onCompleted()
      }

      return Disposables.create {
        task.cancel()
      }
    }
  }

  func updateAndNavigateToSearchResult(_ searchString: String) {
    Task {
      try await self.workbench.write { transaction in
        transaction.update(RecentSearchObject(query: searchString, date: .now))
      }
      self.steps.accept(AppStep.searchResultIsRequired(searchString))
    }
  }
}
