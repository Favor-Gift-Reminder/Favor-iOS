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
    var currentFriendCount: Int
    var sectionType: NewGiftFriendSectionType
  }
  
  // MARK: - Properties
  
  var initialState: State
  
  // MARK: - Initialzier
  
  init(section: NewGiftFriendSection.NewGiftFriendSectionModel) {
    self.initialState = State(
      currentFriendCount: section.items.count,
      sectionType: section.model
    )
  }
}
