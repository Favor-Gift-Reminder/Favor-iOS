//
//  NewGiftFriendHeaderViewReactor.swift
//  Favor
//
//  Created by 김응철 on 2023/04/15.
//

import ReactorKit

final class NewGiftFriendHeaderViewReactor: Reactor {
  typealias Action = NoAction
  
  struct State {
    var sectionModel: NewGiftFriendSection.NewGiftFriendSectionModel
  }
  
  // MARK: - Properties
  
  var initialState: State
  
  // MARK: - Initialzier
  
  init(sectionModel: NewGiftFriendSection.NewGiftFriendSectionModel) {
    self.initialState = State(
      sectionModel: sectionModel
    )
  }
}
