//
//  MyPageSectionHeaderViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/02/14.
//

import ReactorKit

final class MyPageSectionHeaderViewReactor: Reactor {
  
  // MARK: - Properties
  
  var initialState: State
  
  enum Action {
    
  }
  
  enum Mutation {
    
  }
  
  struct State {
    var title: String?
    var sectionType: MyPageSection?
  }
  
  // MARK: - Initializer
  
  init(section: MyPageSection) {
    self.initialState = State(
      sectionType: section
    )
  }

  init(title: String) {
    self.initialState = State(
      title: title
    )
  }
  
  
  // MARK: - Functions
  

}
