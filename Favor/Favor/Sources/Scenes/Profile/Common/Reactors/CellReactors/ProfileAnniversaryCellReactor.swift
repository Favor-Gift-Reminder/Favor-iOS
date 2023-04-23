//
//  ProfileAnniversaryCellReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/02/15.
//

import FavorKit
import ReactorKit

final class ProfileAnniversaryCellReactor: Reactor {
  
  // MARK: - Properties
  
  var initialState: State
  
  enum Action {
    
  }
  
  enum Mutation {
    
  }
  
  struct State {
    var anniversary: Anniversary
  }
  
  // MARK: - Initializer
  
  init(anniversary: Anniversary) {
    self.initialState = State(
      anniversary: anniversary
    )
  }
  
  
  // MARK: - Functions
  

}
