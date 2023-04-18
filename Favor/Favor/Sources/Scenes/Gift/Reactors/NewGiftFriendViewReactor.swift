//
//  NewGiftFriendViewReactor.swift
//  Favor
//
//  Created by 김응철 on 2023/04/15.
//

import UIKit

import FavorKit
import ReactorKit
import RxCocoa
import RxFlow

final class NewGiftFriendViewReactor: Reactor, Stepper {
  
  enum Action {
    case choiceFriendButtonDidTap
  }
  
  enum Mutation {
    case setSelectedSection(NewGiftFriendSection.NewGiftFriendSectionModel)
    case setFriendListSection(NewGiftFriendSection.NewGiftFriendSectionModel)
  }
  
  struct State {
    var selectedSection = NewGiftFriendSection.NewGiftFriendSectionModel(
      model: .selectedFriends,
      items: [.empty]
    )
    var friendListSection = NewGiftFriendSection.NewGiftFriendSectionModel(
      model: .friendList,
      items: [.friend(.init())]
    )
  }
  
  // MARK: - Properties
  
  var initialState: State = State()
  var steps = PublishRelay<Step>()
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .choiceFriendButtonDidTap:
      self.steps.accept(AppStep.newGiftFriendIsRequired)
      return .empty()
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setFriendListSection(let model):
      newState.friendListSection = model
    case .setSelectedSection(let model):
      newState.selectedSection = model
    }
    
    return newState
  }
}
