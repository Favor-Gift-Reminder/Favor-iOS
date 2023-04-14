//
//  ReminderCellReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/03/30.
//

import UIKit.UIImage

import ReactorKit

final class ReminderCellReactor: Reactor {

  // MARK: - Properties

  var initialState: State

  enum Action {
    case notifySwitchDidTap
  }

  enum Mutation {

  }

  struct State {
    var reminderData: Reminder
  }

  // MARK: - Initializer

  init(reminder: Reminder) {
    self.initialState = State(
      reminderData: reminder
    )
  }


  // MARK: - Functions

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .notifySwitchDidTap:
      // Update Reminder
      return .empty()
    }
  }
}
