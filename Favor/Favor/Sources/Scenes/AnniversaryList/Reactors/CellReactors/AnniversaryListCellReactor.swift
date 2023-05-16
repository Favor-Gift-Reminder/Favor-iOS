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

  }

  public enum Mutation {

  }

  public struct State {
    var cellType: AnniversaryListCell.CellType = .list
    var anniversary: Anniversary
  }

  // MARK: - Initializer

  init(anniversary: Anniversary) {
    self.initialState = State(
      anniversary: anniversary
    )
  }

  // MARK: - Functions

}
