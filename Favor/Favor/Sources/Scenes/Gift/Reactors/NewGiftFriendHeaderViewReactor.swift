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
    var currentFriendCount: Int = 0
    var sectionType: NewGiftFriendSectionType = .selectedFriends
  }
  
  // MARK: - Properties
  
  var initialState: State = State()
  
  // MARK: - Initialzier
  
  init(section: NewGiftFriendSectionType) {
    self.initialState = State(sectionType: section)
  }
}
