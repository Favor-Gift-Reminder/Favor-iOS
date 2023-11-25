//
//  FriendManagementViewReactor.swift
//  Favor
//
//  Created by 김응철 on 2023/05/19.
//

import ReactorKit
import RxCocoa
import RxFlow

public final class FriendManagementViewReactor: Reactor, Stepper {

  public enum Action {
    case textFieldDidChange(String)
    case finishButtonDidTap
  }
  
  public enum Mutation {
    case updateFriendName(String)
  }
  
  public struct State {
    var friendName: String = ""
    var isEnabledFinishButton: Bool = false
  }
  
  // MARK: - Properties
  
  public var steps = PublishRelay<Step>()
  public var initialState: State = State()
  
  // MARK: - Functions
  
  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .textFieldDidChange(let friendName):
      return .just(.updateFriendName(friendName))
    case .finishButtonDidTap:
      self.steps.accept(AppStep.friendManagementIsComplete(self.currentState.friendName))
      return .empty()
    }
  }
  
  public func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .updateFriendName(let friendName):
      newState.friendName = friendName
    }
    
    return newState
  }
  
  public func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      
      newState.isEnabledFinishButton = !state.friendName.isEmpty
      
      return newState
    }
  }
}
