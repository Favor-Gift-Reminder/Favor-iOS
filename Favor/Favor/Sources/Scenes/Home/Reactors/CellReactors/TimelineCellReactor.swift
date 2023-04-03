//
//  TimelineCellReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/01/31.
//

import UIKit

import ReactorKit

final class TimelineCellReactor: Reactor {
  
  // MARK: - Properties
  
  var initialState: State
  
  enum Action {
    
  }
  
  enum Mutation {
    
  }
  
  struct State {
    var gift: Gift
  }
  
  // MARK: - Initializer
  
  init(gift: Gift) {
    self.initialState = State(
      gift: gift
    )
  }
  
  
  // MARK: - Functions
  

}
