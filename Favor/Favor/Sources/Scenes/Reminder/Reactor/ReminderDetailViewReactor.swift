//
//  ReminderDetailViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/04/06.
//

import OSLog

import FavorKit
import ReactorKit
import RxCocoa
import RxFlow

final class ReminderDetailViewReactor: Reactor, Stepper {

  // MARK: - Properties

  var initialState: State
  var steps = PublishRelay<Step>()

  enum Action {
    case editButtonDidTap
    case deleteButtonDidTap
  }

  enum Mutation {

  }

  struct State {
    var reminder: Reminder
  }

  // MARK: - Initializer

  init(reminder: Reminder) {
    self.initialState = State(
      reminder: reminder
    )
  }


  // MARK: - Functions

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .editButtonDidTap:
      self.steps.accept(AppStep.reminderEditIsRequired(self.currentState.reminder))
      return .empty()

    case .deleteButtonDidTap:
      os_log(.debug, "Delete button did tap.")
      return .empty()
    }
  }
}
