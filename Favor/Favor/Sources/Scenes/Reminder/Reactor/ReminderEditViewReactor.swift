//
//  ReminderEditViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/04/02.
//

import OSLog

import FavorKit
import FavorNetworkKit
import ReactorKit
import RxCocoa
import RxFlow

final class ReminderEditViewReactor: Reactor, Stepper {

  // MARK: - Constatns

  public enum EditType {
    case edit, new
  }

  // MARK: - Properties

  var initialState: State
  var steps = PublishRelay<Step>()
  let reminderNetworking = ReminderNetworking()

  enum Action {
    case viewDidLoad
    case doneButtonDidTap
    case datePickerDidUpdate(Date)
    case notifyTimePickerDidUpdate(Date)
    case notifySwitchDidToggle(Bool)
  }

  enum Mutation {
    case updateReminderDate(Date)
    case updateNotifyTime(Date?)
    case updateShouldNotify(Bool)
  }

  struct State {
    var type: EditType
    var reminderEditor: ReminderEditor
    var cachedReminder: Reminder?
  }

  // MARK: - Initializer

  /// type이 `.edit`일 경우 사용합니다.
  init(_ type: EditType = .edit, reminder: Reminder) {
    self.initialState = State(
      type: type,
      reminderEditor: reminder.toDomain(),
      cachedReminder: reminder
    )
  }

  /// type이 `.new`일 경우 사용합니다.
  init(_ type: EditType = .new) {
    self.initialState = State(
      type: type,
      reminderEditor: ReminderEditor()
    )
  }

  // MARK: - Functions

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      if currentState.type == .edit {
        return .merge(
          .just(.updateReminderDate(self.currentState.reminderEditor.date)),
          .just(.updateNotifyTime(self.currentState.reminderEditor.notifyTime))
        )
      } else {
        return .empty()
      }

    case .doneButtonDidTap:
      os_log(.debug, "Done button did tap.")
      print(self.currentState.reminderEditor)
      return .empty()

    case .datePickerDidUpdate(let date):
      return .just(.updateReminderDate(date))

    case .notifyTimePickerDidUpdate(let date):
      return .just(.updateNotifyTime(date))

    case .notifySwitchDidToggle(let isOn):
      return .just(.updateShouldNotify(isOn))
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .updateReminderDate(let date):
      newState.reminderEditor.date = date

    case .updateNotifyTime(let time):
      newState.reminderEditor.notifyTime = time

    case .updateShouldNotify(let shouldNotify):
      newState.reminderEditor.shouldNotify = shouldNotify
    }

    return newState
  }
}
