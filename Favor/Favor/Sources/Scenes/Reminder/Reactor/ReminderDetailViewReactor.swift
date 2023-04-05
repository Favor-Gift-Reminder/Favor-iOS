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
    case editButtonDidTap
    case deleteButtonDidTap
    case cancelButtonDidTap
    case doneButtonDidTap
    case datePickerDidUpdate(String?)
    case notifyTimePickerDidUpdate(String?)
  }

  enum Mutation {
    case switchEditModeTo(Bool)
    case updateReminderDate(Date)
    case updateNotifyTime(Date)
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
    case .editButtonDidTap:
      os_log(.debug, "Edit button did tap.")
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

    case .datePickerDidUpdate(let dateString):
      guard let date = dateString?.toDate("yyyy년 M월 d일") else { return .empty() }
      return .just(.updateReminderDate(date))

    case .notifyTimePickerDidUpdate(let timeString):
      guard let time = timeString?.toDate("a h시 m분") else { return .empty() }
      return .just(.updateNotifyTime(time))
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
