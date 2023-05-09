//
//  ProfileFavorCellReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/02/15.
//

import FavorKit
import ReactorKit

final class ProfileFavorCellReactor: Reactor {
  
  // MARK: - Properties
  
  var initialState: State
  
  enum Action {
    
  }
  
  enum Mutation {
    
  }
  
  struct State {
    var favor: Favor
  }
  
  // MARK: - Initializer
  
  init(favor: Favor) {
    self.initialState = State(
      favor: favor
    )
  }
  
  
  // MARK: - Functions
  

}
