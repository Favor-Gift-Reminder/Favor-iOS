//
//  ProfileFriendCellReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/02/22.
//

import FavorKit
import ReactorKit

final class ProfileFriendCellReactor: Reactor {

  // MARK: - Properties

  var initialState: State

  enum Action {

  }

  enum Mutation {

  }

  struct State {
    var friend: Friend
    var isNewFriendCell: Bool
  }

  // MARK: - Initializer

  init(friend: Friend, isNewFriendCell: Bool = false) {
    self.initialState = State(
      friend: friend,
      isNewFriendCell: isNewFriendCell
    )
  }


  // MARK: - Functions


}
