//
//  TermViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/03/02.
//

import ReactorKit
import RxCocoa
import RxFlow

final class TermViewReactor: Reactor, Stepper {

  // MARK: - Properties

  var initialState: State
  var steps = PublishRelay<Step>()

  enum Action {

  }

  enum Mutation {

  }

  struct State {
    var userName: String
  }

  // MARK: - Initializer

  init(with userName: String) {
    self.initialState = State(
      userName: userName
    )
  }


  // MARK: - Functions


}
