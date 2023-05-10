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
  }

  // MARK: - Initializer

  init(friend: Friend) {
    self.initialState = State(
      friend: friend
    )
  }


  // MARK: - Functions


}
