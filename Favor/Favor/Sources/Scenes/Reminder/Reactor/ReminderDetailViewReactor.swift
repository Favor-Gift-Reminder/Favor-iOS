//
//  ReminderDetailViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/04/02.
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
    case viewDidLoad
    case editButtonDidTap
    case deleteButtonDidTap
    case cancelButtonDidTap
    case doneButtonDidTap
    case datePickerDidUpdate(Date)
    case notifyTimePickerDidUpdate(Date)
  }

  enum Mutation {
    case switchEditModeTo(Bool)
    case updateReminderDate(Date)
    case updateNotifyTime(Date?)
    case applyEditAction(EditAction)
  }

  struct State {
    var isEditable: Bool = false
    var reminderEditor: ReminderEditor
    var cachedReminder: ReminderEditor
  }

  // MARK: - Initializer

  init(reminder: Reminder) {
    let wrappedReminder = reminder.toDomain()
    self.initialState = State(
      reminderEditor: wrappedReminder,
      cachedReminder: wrappedReminder
    )
  }


  // MARK: - Functions

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      return .merge(
        .just(.updateReminderDate(self.currentState.cachedReminder.date)),
        .just(.updateNotifyTime(self.currentState.cachedReminder.notifyTime))
      )

    case .editButtonDidTap:
      return .just(.switchEditModeTo(true))

    case .deleteButtonDidTap:
      os_log(.debug, "Delete button did tap.")
      return .empty()

    case .cancelButtonDidTap:
      return .merge(
        .just(.switchEditModeTo(false)),
        .just(.applyEditAction(.cancel))
      )

    case .doneButtonDidTap:
      return .merge(
        .just(.switchEditModeTo(false)),
        .just(.applyEditAction(.apply))
      )

    case .datePickerDidUpdate(let date):
      return .just(.updateReminderDate(date))

    case .notifyTimePickerDidUpdate(let date):
      return .just(.updateNotifyTime(date))
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .switchEditModeTo(let isEditable):
      newState.isEditable = isEditable

    case .updateReminderDate(let date):
      newState.reminderEditor.date = date

    case .updateNotifyTime(let time):
      newState.reminderEditor.notifyTime = time

    case .applyEditAction(let action):
      switch action {
      case .apply:
        newState.cachedReminder = state.reminderEditor
      case .cancel:
        newState.reminderEditor = state.cachedReminder
      }
    }

    return newState
  }
}
