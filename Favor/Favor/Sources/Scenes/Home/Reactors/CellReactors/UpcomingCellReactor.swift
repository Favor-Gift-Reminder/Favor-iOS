//
//  UpcomingCellReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/01/31.
//

import UIKit

import ReactorKit

final class UpcomingCellReactor: Reactor {
  
  // MARK: - Properties
  
  var initialState: State
  
  enum Action {
    
  }
  
  enum Mutation {
    
  }
  
  struct State {
    var reminder: Reminder
  }
  
  // MARK: - Initializer
  
  init(reminder: Reminder) {
    self.initialState = State(
      reminder: reminder
    )
  }
  
}
