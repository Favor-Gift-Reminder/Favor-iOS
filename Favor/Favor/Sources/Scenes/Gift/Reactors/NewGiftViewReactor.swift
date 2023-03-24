//
//  NewGiftViewReactor.swift
//  Favor
//
//  Created by 김응철 on 2023/02/09.
//

import FavorKit
import ReactorKit

final class NewGiftViewReactor: Reactor {
  
  enum Action {
    case giftReceivedButtonDidTap
    case giftGivenButtonDidTap
    case titleTextFieldDidChange(String)
  }
  
  enum Mutation {
    case setReceivedGift(Bool)
    case setCategory(FavorCategory)
    case setTitle(String)
  }
  
  struct State {    
    var isReceivedGift: Bool = true
    var currentCategory: FavorCategory = .lightGift
    var currentTitle: String = ""
  }
  
  var initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .giftGivenButtonDidTap:
      return .just(.setReceivedGift(false))
      
    case .giftReceivedButtonDidTap:
      return .just(.setReceivedGift(true))
      
    case .titleTextFieldDidChange(let title):
      return .just(.setTitle(title))
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setReceivedGift(let state):
      newState.isReceivedGift = state
      
    case .setCategory(let category):
      newState.currentCategory = category
      
    case .setTitle(let title):
      newState.currentTitle = title
    }
    
    return newState
  }
}
