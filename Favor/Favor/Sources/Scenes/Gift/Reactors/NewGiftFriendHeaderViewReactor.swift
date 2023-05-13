//
//  NewGiftFriendHeaderViewReactor.swift
//  Favor
//
//  Created by 김응철 on 2023/05/11.
//

import FavorKit

import ReactorKit

final class NewGiftFriendHeaderViewReactor: Reactor {
  typealias Action = NoAction

  struct State {
    var section: NewGiftFriendSection
    var friends: [Friend]
  }
  
  // MARK: - Properties
  
  var initialState: State
  
  // MARK: - Initializer
  
  init(_ section: NewGiftFriendSection, friends: [Friend]) {
    self.initialState = State(section: section, friends: friends)
  }
}
