//
//  ProfilePreferenceCellReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/02/15.
//

import ReactorKit

final class ProfilePreferenceCellReactor: Reactor {
  
  // MARK: - Properties
  
  var initialState: State
  
  enum Action {
    
  }
  
  enum Mutation {
    
  }
  
  struct State {
    var preference: String
  }
  
  // MARK: - Initializer
  
  init(preference: String) {
    self.initialState = State(
      preference: preference
    )
  }
  
  
  // MARK: - Functions
  

}
