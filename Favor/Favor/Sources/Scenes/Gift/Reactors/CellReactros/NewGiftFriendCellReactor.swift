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
  
  typealias Action = NoAction
  
  struct State {
    var rightButtonState: NewGiftFriendCell.RightButtonType = .add
    var friend: Friend
  }
  
  // MARK: - Properties
  
  var initialState: State
  
  // MARK: - Initializer
  
  init(
    _ friend: Friend,
    rightButtonState: NewGiftFriendCell.RightButtonType
  ) {
    self.initialState = State(
      rightButtonState: rightButtonState,
      friend: friend
    )
  }
}
