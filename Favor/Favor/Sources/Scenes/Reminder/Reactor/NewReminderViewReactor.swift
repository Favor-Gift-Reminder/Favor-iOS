//
//  NewReminderViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/03/31.
//

import UIKit
import OSLog

import FavorKit
import ReactorKit
import RxCocoa
import RxFlow

final class NewReminderViewReactor: Reactor, Stepper {

  // MARK: - Properties

  var initialState: State
  var steps = PublishRelay<Step>()

  enum Action {
    case viewDidPop
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
    case .viewDidPop:
      self.steps.accept(AppStep.newReminderIsComplete)
      return .empty()
    }
  }
}
