//
//  FriendListModifyingViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/05/10.
//

import FavorKit
import FavorNetworkKit
import ReactorKit
import RxCocoa
import RxFlow

final class FriendListModifyingViewReactor: BaseFriendListViewReactor, Reactor, Stepper {

  // MARK: - Properties

  var initialState: State
  var steps = PublishRelay<Step>()
  let friendNetworking = FriendNetworking()

  enum Action {
    case viewNeedsLoaded
    case deleteButtonDidTap(Friend)
  }

  enum Mutation {
    case updateFriendItems([FriendSectionItem])
  }

  struct State {
    var sections: [FriendSection] = [.editFriend]
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
      return self.friendFetcher.fetch()
        .flatMap { (status, friends) -> Observable<Mutation> in
          let friendItems = friends.toArray().map { friend -> FriendSectionItem in
            return .friend(friend)
          }
          return .just(.updateFriendItems(friendItems))
        }

    case .deleteButtonDidTap(let friend):
      return self.friendNetworking.request(.deleteFriend(friendNo: friend.friendNo))
        .flatMap { response -> Observable<Mutation> in
          do {
            let response: ResponseDTO<FriendResponseDTO> = try APIManager.decode(response.data)
            print(response.responseMessage)
            return self.friendFetcher.fetch()
              .flatMap { (status, friends) -> Observable<Mutation> in
                let friendItems = friends.toArray().map { friend -> FriendSectionItem in
                  return .friend(friend)
                }
                return .just(.updateFriendItems(friendItems))
              }
          } catch {
            print(error)
            return .empty()
          }
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
