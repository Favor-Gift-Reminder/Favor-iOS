//
//  NewGiftFriendCellReactor.swift
//  Favor
//
//  Created by 김응철 on 2023/04/14.
//

import UIKit

import FavorKit
import ReactorKit

final class NewGiftFriendCellReactor: Reactor {
  static func == (
    lhs: NewGiftFriendCellReactor,
    rhs: NewGiftFriendCellReactor
  ) -> Bool {
    return lhs.currentState == rhs.currentState
  }
  
  typealias Action = NoAction
  
  struct State: Hashable {
    var rightButtonState: FriendSelectorCell.RightButtonType = .add
    var friend: Friend
  }
  
  // MARK: - Properties
  
  var initialState: State
  
  // MARK: - Initializer
  
  init(
    _ friend: Friend,
    rightButtonState: FriendSelectorCell.RightButtonType
  ) {
    self.initialState = State(
      rightButtonState: rightButtonState,
      friend: friend
    )
  }
}
