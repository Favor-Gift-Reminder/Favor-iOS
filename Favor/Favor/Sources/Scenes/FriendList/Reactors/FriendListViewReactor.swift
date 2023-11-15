//
//  FriendListViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/04/25.
//

import OSLog

import FavorKit
import FavorNetworkKit
import ReactorKit
import RxCocoa
import RxFlow

final class FriendListViewReactor: BaseFriendListViewReactor, Reactor, Stepper {

  // MARK: - Properties
  
  var initialState: State
  var steps = PublishRelay<Step>()

  enum Action {
    case viewNeedsLoaded
    case editButtonDidTap
    case searchTextDidUpdate(String?)
    case friendCellDidTap(Int)
  }
  
  enum Mutation {
    case updateFriends([Friend])
    case updateQuery(String)
  }
  
  struct State {
    var friends: [Friend] = []
    var sections: [FriendSection] = []
    var items: [[FriendSectionItem]] = []
    var query: String = ""
  }

  // MARK: - Initializer

  override init() {
    self.initialState = State()
    super.init()
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewNeedsLoaded:
      return self.userFetcher.fetch()
        .flatMap { (_, user) -> Observable<Mutation> in
          guard let user = user.first else { return .empty() }
          let friends = user.friendList
          return .just(.updateFriends(friends))
        }
      
    case .editButtonDidTap:
      self.steps.accept(AppStep.editFriendIsRequired)
      return .empty()
      
    case .searchTextDidUpdate(let text):
      return .just(.updateQuery(text ?? ""))
      
    case .friendCellDidTap(let index):
      let friend = self.currentState.friends[index]
      self.steps.accept(AppStep.friendPageIsRequired(friend))
      return .empty()
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .updateFriends(let friends):
      newState.friends = friends
      
    case .updateQuery(let query):
      newState.query = query
    }

    return newState
  }
  
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      
      newState.sections.append(.friend)
      
      if state.query.isEmpty {
        newState.items.append(state.friends.map { FriendSectionItem.friend($0) })
      } else {
        newState.items.append(state.friends
          .filter { $0.friendName.localizedCaseInsensitiveContains(state.query) }
          .map { FriendSectionItem.friend($0) }
        )
      }
      
      return newState
    }
  }
}

// MARK: - Privates

private extension FriendListViewReactor {
  
  
  func fetchFriendList(with query: String) -> Single<[Friend]> {
    return Single<[Friend]>.create { single in
      let task = Task {
        let user = await self.workbench.values(UserObject.self).first
        let friends = user?.friendList.toArray().map { Friend(realmObject: $0) } ?? []
        if query.isEmpty {
          single(.success(friends))
        }
        let filterFriends = friends
          .filter { $0.friendName.contains(query) }
        single(.success(filterFriends))
      }
      return Disposables.create {
        task.cancel()
      }
    }
  }
}
