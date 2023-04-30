//
//  FriendViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/04/25.
//

import OSLog

import ReactorKit
import RxCocoa
import RxFlow

final class FriendViewReactor: Reactor, Stepper {

  // MARK: - Properties

  var initialState: State
  var steps = PublishRelay<Step>()

  enum Action {
    case editButtonDidTap
  }

  enum Mutation {

  }

  struct State {
    var sections: [FriendSection] = [
      .friend([.friend(FriendCellReactor()), .friend(FriendCellReactor())])
    ]
  }

  // MARK: - Initializer

  init() {
    self.initialState = State()
  }

  // MARK: - Functions

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .editButtonDidTap:
      os_log(.debug, "Edit button did tap.")
      return .empty()
    }
  }
}
