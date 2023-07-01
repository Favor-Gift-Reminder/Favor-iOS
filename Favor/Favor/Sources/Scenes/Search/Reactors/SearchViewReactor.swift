//
//  SearchViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/02/07.
//

import OSLog

import FavorKit
import FavorNetworkKit
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
  private let giftFetcher = Fetcher<Gift>()
  private let mode: SearchViewMode
  private var tasks: Set<Task<Void, Error>> = []

  enum Action {
    case viewNeedsLoaded
    case editingDidBegin
    case textDidChanged(String?)
    case editingDidEnd
    case categoryButtonDidTap(FavorCategory)
    case emotionButtonDidTap(FavorEmotion)
    case returnKeyDidTap
    case searchRecentDidSelected(String)
    case searchRecentDeleteButtonDidTap(RecentSearch)
    case searchRequestedWith(String)
    case searchTypeDidSelected(SearchType)
    case viewWillDisappear
    case doNothing
  }
  
  enum Mutation {
    case toggleIsEditingTo(Bool)
    case updateText(String?)
    case updateRecentSearches([RecentSearch])
    case updateSearchType(SearchType)
    case updateSearchTypeBySearchResult
    case updateGiftResult([Gift])
    case updateUserResult([User])
  }
  
  struct State {
    var isEditing: Bool = false
    var isRecentSearchVisible: Bool = false
    var searchQuery: String?
    var recentSearches: [RecentSearch] = []
    var recentSearchItems: [SearchSectionItem] = []
    // Search Results
    var didUserSelectedSearchType: Bool = false
    var selectedSearchType: SearchType = .gift
    var giftSearchResults: [Gift] = []
    var giftSearchResultItems: [SearchResultSectionItem] = []
    var userSearchResults: [User] = []
    var userSearchResultItems: [SearchResultSectionItem] = []
  }
  
  // MARK: - Initializer
  
  init(mode: SearchViewMode, searchQuery: String? = nil) {
    self.initialState = State(
      searchQuery: searchQuery
    )
    self.mode = mode
    if let searchQuery {
      self.setupGiftFetcher(with: searchQuery)
    }
  }

  deinit {
    self.tasks.forEach { $0.cancel() }
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
      self.steps.accept(AppStep.searchCategoryResultIsRequired(category))
      return .empty()

    case .emotionButtonDidTap(let emotion):
      self.steps.accept(AppStep.searchEmotionResultIsRequired(emotion))
      return .empty()

    // transform에서 처리
    case .returnKeyDidTap:
      return .empty()

    // transform에서 처리
    case .searchRecentDidSelected:
      return .empty()

    case .searchRecentDeleteButtonDidTap(let recentSearch):
      return self.deleteRecentSearch(recentSearch)
        .asObservable()
        .flatMap { recentSearch -> Observable<Mutation> in
          var newRecentSearches = self.currentState.recentSearches
          newRecentSearches.removeAll { $0 == recentSearch }
          return .just(.updateRecentSearches(newRecentSearches))
        }

    case .searchRequestedWith(let searchQuery):
      switch self.mode {
      case .search:
        self.updateAndNavigateToSearchResult(searchQuery)
        return .just(.toggleIsEditingTo(false))
      case .result:
        self.setupGiftFetcher(with: searchQuery)
        return .concat(
          self.giftFetcher.fetch()
            .flatMap { fetchResult -> Observable<Mutation> in
              let (_, gifts) = fetchResult
              return .just(.updateGiftResult(gifts))
            },
          self.fetchRemoteUser(with: searchQuery)
            .asObservable()
            .flatMap { (user: User?) -> Observable<Mutation> in
              if let user {
                return .just(.updateUserResult([user]))
              } else {
                return .just(.updateUserResult([]))
              }
            },
          .just(.toggleIsEditingTo(false)),
          .just(.updateSearchTypeBySearchResult)
        )
      }

    case .searchTypeDidSelected(let searchType):
      return .just(.updateSearchType(searchType))

    case .doNothing:
      return .empty()
    }
  }

  func transform(action: Observable<Action>) -> Observable<Action> {
    return action.map { action in
      switch action {
      case .returnKeyDidTap:
        guard let searchQuery = self.currentState.searchQuery else { return .doNothing }
        return .searchRequestedWith(searchQuery)
      case .searchRecentDidSelected(let searchQuery):
        return .searchRequestedWith(searchQuery)
      default:
        return action
      }
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
      newState.didUserSelectedSearchType = true
      newState.selectedSearchType = searchType

    case .updateSearchTypeBySearchResult:
      if !self.currentState.didUserSelectedSearchType {
        if self.currentState.giftSearchResults.isEmpty && !self.currentState.userSearchResults.isEmpty {
          newState.selectedSearchType = .user
        } else if !self.currentState.giftSearchResults.isEmpty && self.currentState.userSearchResults.isEmpty {
          newState.selectedSearchType = .gift
        }
      }

    case .updateGiftResult(let gifts):
      newState.giftSearchResults = gifts

    case .updateUserResult(let users):
      newState.userSearchResults = users
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

      if !state.recentSearches.isEmpty && state.isEditing {
        newState.isRecentSearchVisible = true
      }

      return newState
    }
  }
}

// MARK: - Privates

private extension SearchViewReactor {
  func updateAndNavigateToSearchResult(_ searchString: String) {
    let task = Task {
      try await self.workbench.write { transaction in
        transaction.update(RecentSearchObject(query: searchString, date: .now))
      }
      self.steps.accept(AppStep.searchResultIsRequired(searchString))
    }
    self.tasks.insert(task)
  }

  func deleteRecentSearch(_ recentSearch: RecentSearch) -> Single<RecentSearch> {
    return Single<RecentSearch>.create { single in
      let task = Task {
        do {
          try await self.workbench.write { transaction in
            transaction.delete(recentSearch.realmObject())
            single(.success(recentSearch))
          }
        } catch {
          single(.failure(error))
        }
      }

      return Disposables.create {
        task.cancel()
      }
    }
  }
}

// MARK: - Fetcher

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

  func setupGiftFetcher(with queryString: String) {
    // onRemote
    self.giftFetcher.onRemote = {
      let networking = UserNetworking()
      let gifts = networking.request(.getGiftByName(giftName: queryString))
        .flatMap { response -> Observable<[Gift]> in
          let responseDTO: ResponseDTO<[GiftResponseDTO]> = try APIManager.decode(response.data)
          return .just(responseDTO.data.map { Gift(dto: $0) })
        }
        .asSingle()
      return gifts
    }
    // onLocal
    self.giftFetcher.onLocal = {
      return await self.workbench.values(GiftObject.self)
        .where { $0.name.contains(queryString) }
        .map { Gift(realmObject: $0) }
    }
    // onLocalUpdate
    self.giftFetcher.onLocalUpdate = { _, remoteGifts in
      try await self.workbench.write { transaction in
        transaction.update(remoteGifts.map { $0.realmObject() })
      }
    }
  }

  func fetchRemoteUser(with queryString: String) -> Single<User?> {
    return Single<User?>.create { single in
      let networking = UserNetworking()
      let disposable = networking.request(.getUserId(userId: queryString))
        .take(1)
        .asSingle()
      // FIXME: DecodeError 처리 필요..! ResponseMessage가 "USER_NOT_FOUND"일 때
        .subscribe(onSuccess: { response in
          do {
            let responseDTO: ResponseDTO<UserResponseDTO> = try APIManager.decode(response.data)
            single(.success(User(dto: responseDTO.data)))
          } catch {
            print(error)
          }
        }, onFailure: {_ in 
          single(.success(nil))
        })

      return Disposables.create {
        disposable.dispose()
      }
    }
  }
}
