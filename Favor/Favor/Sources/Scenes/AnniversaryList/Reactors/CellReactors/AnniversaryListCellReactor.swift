//
//  AnniversaryListCellReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/05/16.
//

import FavorKit
import ReactorKit

public final class AnniversaryListCellReactor: Reactor {

  // MARK: - Properties

  public var initialState: State

  public enum Action {
    case rightButtonDidTap
  }

  public enum Mutation {
    case toggleIsPinned
  }

  public struct State {
    var cellType: AnniversaryListCell.CellType
    var anniversary: Anniversary
  }

  // MARK: - Initializer

  init(cellType: AnniversaryListCell.CellType, anniversary: Anniversary) {
    self.initialState = State(
      cellType: cellType,
      anniversary: anniversary
    )
  }

  // MARK: - Functions

  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .rightButtonDidTap:
      return .empty()
    }
  }

  public func reduce(state: State, mutation: Mutation) -> State {
    let newState = state

    switch mutation {
    case .toggleIsPinned:
      newState.anniversary.isPinned.toggle()
    }

    return newState
  }
}
