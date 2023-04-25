//
//  EditMyPagePreferenceCellReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/04/25.
//

import ReactorKit

final class EditMyPagePreferenceCellReactor: Reactor {

  // MARK: - Properties

  var initialState: State

  enum Action {

  }

  enum Mutation {

  }

  struct State {
    var favor: String
  }

  // MARK: - Initializer

  public init(favor: String) {
    self.initialState = State(
      favor: favor
    )
  }

  // MARK: - Functions

}
