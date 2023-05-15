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

final class FriendListViewReactor: BaseFriendReactor, Reactor, Stepper {

  // MARK: - Properties

  var initialState: State
  var steps = PublishRelay<Step>()

  enum Action {
    case viewNeedsLoaded
    case editButtonDidTap
    case searchTextDidUpdate(String?)
  }

  enum Mutation {
    case updateFriendItems([FriendSectionItem])
  }

  struct State {
    var sections: [FriendSection] = [.friend]
    var items: [[FriendSectionItem]] = []
    var friendItems: [FriendSectionItem] = []
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
      return self.friendsFetcher.fetch()
        .flatMap { (status, friends) -> Observable<Mutation> in
          let friendItems = friends.toArray().map { friend -> FriendSectionItem in
            return .friend(friend)
          }
          return .just(.updateFriendItems(friendItems))
        }

    case .editButtonDidTap:
      self.steps.accept(AppStep.editFriendIsRequired)
      return .empty()

    case .searchTextDidUpdate(let text):
      return self.fetchFriendList(with: text ?? "")
        .asObservable()
        .flatMap { friends -> Observable<Mutation> in
          let friendItems = friends.map { friend -> FriendSectionItem in
            return .friend(friend)
          }
          return .just(.updateFriendItems(friendItems))
        }
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .updateFriendItems(let friendItems):
      newState.friendItems = friendItems
    }

    return newState
  }

  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      newState.items.append(state.friendItems)
      return newState
    }
  }
}

// MARK: - Privates

private extension FriendListViewReactor {
  func fetchFriendList(with query: String) -> Single<[Friend]> {
    return Single<[Friend]>.create { single in
      let task = Task {
        do {
          let friends = try await RealmManager.shared.read(Friend.self)
          if query.isEmpty {
            single(.success(await friends.toArray()))
          }
          let filterFriends = await friends
            .where { $0.name.contains(query, options: .diacriticInsensitive) }
            .toArray()
          single(.success(filterFriends))
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
