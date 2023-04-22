//
//  ProfileSetupHelperCellReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/02/15.
//

import ReactorKit

final class ProfileSetupHelperCellReactor: Reactor {

  // MARK: - Constants

  public enum ProfileHelperType {
    case preference, anniversary
  }
  
  // MARK: - Properties
  
  var initialState: State
  
  enum Action {
    
  }
  
  enum Mutation {
    
  }
  
  struct State {
    var type: ProfileHelperType
  }
  
  // MARK: - Initializer
  
  init(_ type: ProfileHelperType) {
    self.initialState = State(
      type: type
    )
  }
  
  
  // MARK: - Functions
  

}
