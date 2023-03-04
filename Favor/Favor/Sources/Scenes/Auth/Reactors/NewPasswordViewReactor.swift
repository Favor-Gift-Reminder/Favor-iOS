//
//  NewPasswordViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/03/04.
//

import ReactorKit
import RxCocoa
import RxFlow

final class NewPasswordViewReactor: Reactor, Stepper {

  // MARK: - Properties

  var initialState: State
  var steps = PublishRelay<Step>()

  enum Action {
    case nextFlowRequested
  }

  enum Mutation {

  }

  struct State {

  }

  // MARK: - Initializer

  init() {
    self.initialState = State()
  }


  // MARK: - Functions

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .nextFlowRequested:
      return .empty()
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {

    }

    return newState
  }
}
