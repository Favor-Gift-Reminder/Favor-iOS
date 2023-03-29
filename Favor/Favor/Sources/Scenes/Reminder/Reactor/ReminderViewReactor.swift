//
//  ReminderViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/03/29.
//

import ReactorKit
import RxCocoa
import RxFlow

final class ReminderViewReactor: Reactor, Stepper {

  // MARK: - Properties

  var initialState: State
  var steps = PublishRelay<Step>()

  enum Action {

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


}
