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
    @Pulse var shouldShowPopup: Int?
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
          let friendItems = user.friendList.map { friend -> FriendSectionItem in
            return .friend(friend)
          }
          return .just(.updateFriendItems(friendItems))
        }
      
    case .deleteButtonDidTap(let friend):
      return self.friendNetworking.request(.deleteFriend(friendNo: friend.identifier))   
        .flatMap { _ in
          Task {
            try await self.workbench.write { transaction in
              transaction.delete(friend.realmObject())
            }
            self.action.onNext(.viewNeedsLoaded)
          }
          return Observable<Mutation>.empty()
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
