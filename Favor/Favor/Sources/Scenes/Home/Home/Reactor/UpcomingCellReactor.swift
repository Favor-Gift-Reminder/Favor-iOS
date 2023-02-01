//
//  UpcomingCellReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/01/31.
//

import ReactorKit

final class UpcomingCellReactor: Reactor {
  
  // MARK: - Properties
  
  var initialState: State
  
  enum Action {
    
  }
  
  enum Mutation {
    
  }
  
  struct State {
    var text: String
  }
  
  // MARK: - Initializer
  
  init(text: String) {
    self.initialState = State(
      text: text
    )
  }
  
}
