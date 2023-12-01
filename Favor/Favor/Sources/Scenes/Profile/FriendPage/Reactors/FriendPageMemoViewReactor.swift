//
//  FriendPageMemoViewReactor.swift
//  Favor
//
//  Created by 김응철 on 11/25/23.
//

import Foundation

import FavorKit
import FavorNetworkKit
import ReactorKit
import RxFlow
import RxCocoa

final class FriendPageMemoViewReactor: Reactor, Stepper {
  
  enum Action {
    case memoDidChange(String)
    case doneButtonDidTap
  }
  
  enum Mutation {
    case updateMemo(String)
  }
  
  struct State {
    var memo: String
    var friend: Friend
    var isEnabledDoneButton: Bool = false
  }
  
  // MARK: - Properties
  
  var initialState: State
  var steps = PublishRelay<Step>()
  var workBench = RealmWorkbench()
  
  // MARK: - Initializer
  
  init(_ friend: Friend) {
    self.initialState = State(memo: friend.memo, friend: friend)
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .memoDidChange(let memo):
      return .just(.updateMemo(memo))
      
    case .doneButtonDidTap:
      return self.requestPatchFriendMemo()
        .flatMap { _ in
          self.steps.accept(AppStep.friendPageMemoIsComplete)
          return Observable<Mutation>.empty()
        }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .updateMemo(let memo):
      newState.memo = memo
    }
    
    return newState
  }
  
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      
      newState.isEnabledDoneButton = !state.memo.isEmpty
      
      return newState
    }
  }
}

// MARK: - Network

private extension FriendPageMemoViewReactor {
  func requestPatchFriendMemo() -> Observable<Void> {
    let memo = self.currentState.memo
    let friendNo = self.currentState.friend.identifier
    return Observable<Void>.create { observer in
      let networking = FriendNetworking()
      return networking.request(.patchFriendMemo(memo: memo, friendNo: friendNo), loadingIndicator: true)
        .map(ResponseDTO<FriendSingleResponseDTO>.self)
        .map { Friend(singleDTO: $0.data) }
        .subscribe { friend in
          Task {
            try await self.workBench.write { transaction in
              transaction.update(friend.realmObject())
              observer.onNext(())
              observer.onCompleted()
            }
          }
        }
    }
  }
}
