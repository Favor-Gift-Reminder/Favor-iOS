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
  }
  
  struct State {
    var friends: [Friend] = []
    var sections: [FriendSection] = []
    var items: [[FriendSectionItem]] = []
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
      return self.friendFetcher.fetch()
        .flatMap { (_, friend) -> Observable<Mutation> in
          return .just(.updateFriends(friend))
        }

    case .editButtonDidTap:
      self.steps.accept(AppStep.editFriendIsRequired)
      return .empty()
      
    case .searchTextDidUpdate(let text):
      return self.fetchFriendList(with: text ?? "")
        .asObservable()
        .flatMap { friends -> Observable<Mutation> in
          return .just(.updateFriends(friends))
        }
      
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
    }

    return newState
  }
  
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state

      newState.sections.append(.friend)
      newState.items.append(state.friends.map { FriendSectionItem.friend($0) })
      
      return newState
    }
  }
}

// MARK: - Privates

private extension FriendListViewReactor {
  func fetchFriendList(with query: String) -> Single<[Friend]> {
    return Single<[Friend]>.create { single in
      let task = Task {
        let friends = await self.workbench.values(FriendObject.self)
        if query.isEmpty {
          single(.success(friends.map { Friend(realmObject: $0) }))
        }
        let filterFriends = friends
          .where { $0.friendName.contains(query, options: .diacriticInsensitive) }
        single(.success(filterFriends.map { Friend(realmObject: $0) }))
      }
      return Disposables.create {
        task.cancel()
      }
    }
  }
}
