//
//  EditMyPagePreferenceCellReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/04/25.
//

import FavorKit
import ReactorKit

final class EditMyPagePreferenceCellReactor: Reactor {

  // MARK: - Properties

  var initialState: State

  enum Action {

  }

  enum Mutation {

  }

  struct State {
    var favor: Favor
    var isSelected: Bool
  }

  // MARK: - Initializer

  public init(favor: Favor, isSelected: Bool = false) {
    self.initialState = State(
      favor: favor,
      isSelected: isSelected
    )
  }

  // MARK: - Functions

}
