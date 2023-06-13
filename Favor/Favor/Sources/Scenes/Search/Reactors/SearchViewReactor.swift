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
  private let workbench = RealmWorkbench()
  private let mode: SearchViewMode

  enum Action {
    case viewNeedsLoaded
    case editingDidBegin
    case textDidChanged(String?)
    case editingDidEnd
    case categoryButtonDidTap(FavorCategory)
    case returnKeyDidTap
    case searchRecentDidSelected(String)
    case searchTypeDidSelected(SearchType)
    case viewWillDisappear
    case doNothing
  }
  
  enum Mutation {
    case toggleIsEditingTo(Bool)
    case updateText(String?)
    case updateRecentSearches([RecentSearch])
    case updateSearchType(SearchType)
  }
  
  struct State {
    var isEditing: Bool = false
    var searchQuery: String?
    var recentSearches: [RecentSearch] = []
    var recentSearchItems: [SearchSectionItem] = []
    var selectedSearchType: SearchType = .gift
    var giftSearchResults: [Gift] = [
      Gift()
    ]
    var giftSearchResultItems: [SearchResultSectionItem] = []
    var userSearchResults: [User] = [
      User()
    ]
    var userSearchResultItems: [SearchResultSectionItem] = []
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
        return self.fetchRecentSearches()
          .flatMap { recentSearches -> Observable<Mutation> in
            let searches = recentSearches.sorted(by: { $0.date > $1.date })
            return .concat([
              .just(.updateRecentSearches(searches)),
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

    case .categoryButtonDidTap(let category):
      print(category.rawValue)
      return .empty()

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

    case .searchRecentDidSelected(let searchString):
      self.updateAndNavigateToSearchResult(searchString)
      return .empty()

    case .searchTypeDidSelected(let searchType):
      return .just(.updateSearchType(searchType))

    case .doNothing:
      return .empty()
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
      newState.recentSearches = recentSearches

    case .updateSearchType(let searchType):
      newState.selectedSearchType = searchType
    }
    
    return newState
  }

  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      // 선물 검색 결과가 비어있을 경우 .empty 데이터 추가
      if state.giftSearchResults.isEmpty {
        newState.giftSearchResultItems = [.empty(nil, "검색 결과가 없습니다.")]
      } else {
        newState.giftSearchResultItems = state.giftSearchResults.map { .gift($0) }
      }
      // 친구 검색 결과가 비어있을 경우 .empty 데이터 추가
      if state.userSearchResults.isEmpty {
        newState.userSearchResultItems = [.empty(nil, "검색 결과가 없습니다.")]
      } else {
        newState.userSearchResultItems = state.userSearchResults.map { .user($0) }
      }

      newState.recentSearchItems = state.recentSearches.map { SearchSectionItem.recent($0) }

      return newState
    }
  }
}

// MARK: - Privates

private extension SearchViewReactor {
  func fetchRecentSearches() -> Observable<[RecentSearch]> {
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
