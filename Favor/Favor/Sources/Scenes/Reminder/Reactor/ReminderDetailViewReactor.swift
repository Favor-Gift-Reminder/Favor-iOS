//
//  ReminderDetailViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/04/02.
//

import OSLog

import ReactorKit
import RxCocoa
import RxFlow

final class ReminderDetailViewReactor: Reactor, Stepper {

  // MARK: - Properties

  var initialState: State
  var steps = PublishRelay<Step>()

  private var cachedReminder: Reminder

  enum Action {
    case editButtonDidTap
    case deleteButtonDidTap
    case cancelButtonDidTap
    case doneButtonDidTap
    case datePickerDidUpdate(String?)
  }

  enum Mutation {
    case switchEditModeTo(Bool)
    case updateReminderDate(Date)
  }

  struct State {
    var isEditable: Bool = false
    var reminderData: Reminder
  }

  // MARK: - Initializer

  init(reminder: Reminder) {
    self.initialState = State(
      reminderData: reminder
    )
    self.cachedReminder = reminder
  }


  // MARK: - Functions

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .editButtonDidTap:
      os_log(.debug, "Edit button did tap.")
      return .just(.switchEditModeTo(true))

    case .deleteButtonDidTap:
      os_log(.debug, "Delete button did tap.")
      return .empty()

    case .cancelButtonDidTap:
      os_log(.debug, "Cancel button did tap.")
      return .just(.switchEditModeTo(false))

    case .doneButtonDidTap:
      os_log(.debug, "Done button did tap.")
      return .just(.switchEditModeTo(false))

    case .datePickerDidUpdate(let dateString):
      guard let date = dateString?.toDate("yyyy년 M월 d일") else { return .empty() }
      return .just(.updateReminderDate(date))
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .switchEditModeTo(let isEditable):
      newState.isEditable = isEditable

    case .updateReminderDate(let date):
      self.cachedReminder.date = date
    }

    return newState
  }
}
