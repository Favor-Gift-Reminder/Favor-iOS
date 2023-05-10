//
//  FriendViewReactor.swift
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

final class FriendViewReactor: Reactor, Stepper {

  // MARK: - Properties

  var initialState: State
  var steps = PublishRelay<Step>()
  let friendsFetcher = Fetcher<[Friend]>()

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

  init() {
    self.initialState = State()
    self.setupFriendFetcher()
  }

  // MARK: - Functions

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewNeedsLoaded:
      return self.friendsFetcher.fetch()
        .flatMap { (status, friends) -> Observable<Mutation> in
          let friendItems = friends.map { friend -> FriendSectionItem in
            return .friend(friend)
          }
          return .just(.updateFriendItems(friendItems))
        }

    case .editButtonDidTap:
      os_log(.debug, "Edit button did tap.")
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

// MARK: - Fetcher

private extension FriendViewReactor {
  func setupFriendFetcher() {
    // onRemote
    self.friendsFetcher.onRemote = {
      let networking = UserNetworking()
      let friends = networking.request(.getAllFriendList(userNo: UserInfoStorage.userNo))
        .flatMap { friends -> Observable<[Friend]> in
          let friendsData = friends.data
          do {
            let remote: ResponseDTO<[FriendResponseDTO]> = try APIManager.decode(friendsData)
            let remoteFriends = remote.data
            let decodedFriends = remoteFriends.map { friend -> Friend in
              return Friend(
                friendNo: friend.friendNo,
                name: friend.friendName,
                profilePhoto: nil,
                memo: friend.friendMemo,
                friendUserNo: friend.friendUserNo,
                isUser: friend.isUser
              )
            }
            return .just(decodedFriends)
          } catch {
            print(error)
            return .just([])
          }
        }
        .asSingle()
      return friends
    }
    // onLocal
    self.friendsFetcher.onLocal = {
      let friends = try await RealmManager.shared.read(Friend.self)
      return await friends.toArray()
    }
    // onLocalUpdate
    self.friendsFetcher.onLocalUpdate = { friends in
      try await RealmManager.shared.updateAll(friends)
    }
  }
}

// MARK: - Privates

private extension FriendViewReactor {
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
