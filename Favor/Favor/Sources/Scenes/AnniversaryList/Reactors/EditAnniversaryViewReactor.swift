//
//  EditAnniversaryViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/05/18.
//

import FavorKit
import ReactorKit
import RxCocoa
import RxFlow

final class EditAnniversaryViewReactor: Reactor, Stepper {

  // MARK: - Properties

  var initialState: State
  var steps = PublishRelay<Step>()

  enum Action {

  }

  enum Mutation {

  }

  struct State {
    var anniversary: Anniversary
  }

  // MARK: - Initializer

  init(with anniversary: Anniversary) {
    self.initialState = State(
      anniversary: anniversary
    )
  }

  // MARK: - Functions

}
