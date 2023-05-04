//
//  SearchUserResultCellReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/04/14.
//

import FavorKit
import ReactorKit

final class SearchUserResultCellReactor: Reactor {

  // MARK: - Properties

  var initialState: State

  enum Action {

  }

  enum Mutation {

  }

  struct State {
    var userData: User = User(userNo: 1, email: "sdfkj", userID: "favor", name: "테스터", favorList: [])
  }

  // MARK: - Initializer

  init() {
    self.initialState = State()
  }


  // MARK: - Functions


}
