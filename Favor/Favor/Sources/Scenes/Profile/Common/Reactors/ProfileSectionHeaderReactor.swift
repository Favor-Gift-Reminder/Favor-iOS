//
//  ProfileSectionHeaderReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/02/14.
//

import ReactorKit

final class ProfileSectionHeaderReactor: Reactor {
  
  // MARK: - Properties
  
  var initialState: State
  
  enum Action {
    
  }
  
  enum Mutation {
    
  }
  
  struct State {
    var title: String?
    var rightButtonTitle: String?
  }
  
  // MARK: - Initializer
  
  init(section: ProfileSection) {
    self.initialState = State(
      title: section.headerTitle,
      rightButtonTitle: section.rightButtonTitle
    )
  }
  
  // MARK: - Functions
  

}
