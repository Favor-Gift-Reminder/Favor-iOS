//
//  SearchGiftResultCellReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/04/14.
//

import FavorKit
import ReactorKit

final class SearchGiftResultCellReactor: Reactor {

  // MARK: - Properties

  var initialState: State

  enum Action {

  }

  enum Mutation {

  }

  struct State {
    var gift: Gift = Gift(giftNo: 0, name: "테스트")
  }

  // MARK: - Initializer

  init() {
    self.initialState = State()
  }


  // MARK: - Functions

}