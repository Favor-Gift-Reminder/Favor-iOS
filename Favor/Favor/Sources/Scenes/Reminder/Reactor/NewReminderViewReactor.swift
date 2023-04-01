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
    case postButtonDidTap
    case viewDidPop
  }

  enum Mutation {
    case setPostButton(Bool)
  }

  struct State {
    var isPostButtonEnabled: Bool = false
  }

  // MARK: - Initializer

  init() {
    self.initialState = State()
  }


  // MARK: - Functions

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .postButtonDidTap:
      os_log(.debug, "Post button did tap.")
      return .empty()

    case .viewDidPop:
      self.steps.accept(AppStep.newReminderIsComplete)
      return .empty()
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .setPostButton(let isEnabled):
      newState.isPostButtonEnabled = isEnabled
    }

    return newState
  }
}
