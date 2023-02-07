//
//  SearchReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/02/07.
//

import ReactorKit
import RxCocoa
import RxFlow

final class SearchReactor: Reactor, Stepper {
  
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
