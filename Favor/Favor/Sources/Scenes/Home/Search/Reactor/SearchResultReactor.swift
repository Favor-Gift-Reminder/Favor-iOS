//
//  SearchResultReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/02/09.
//

import ReactorKit
import RxCocoa
import RxFlow

final class SearchResultReactor: Reactor, Stepper {
  
  // MARK: - Properties
  
  var initialState: State
  var steps = PublishRelay<Step>()
  
  enum Action {
    
  }
  
  enum Mutation {
    
  }
  
  struct State {
    
  }
  
  // MARK: - Initializer
  
  init() {
    self.initialState = State()
  }
  
  
  // MARK: - Functions
  

}
