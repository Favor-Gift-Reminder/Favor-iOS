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
    let profileImage: BaseFriendCell.FriendCellType = .undefined
    let friendName: String = "안녕하세요"
    let rightButtonState: NewGiftFriendCell.RightButtonType = .add
  }
  
  var initialState: State = State()
}
