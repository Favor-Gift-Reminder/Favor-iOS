//
//  NewReminderViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/03/31.
//

import UIKit

import FavorKit
import ReactorKit
import RxCocoa
import RxFlow

final class NewReminderViewReactor: Reactor, Stepper {

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
