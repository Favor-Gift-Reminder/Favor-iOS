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
    case datePickerDidUpdate(Date?)
    case notifyTimePickerDidUpdate(Date?)
    case notifySwitchDidToggle(Bool)
  }

  enum Mutation {
    case updateReminderDate(Date?)
    case updateNotifyTime(Date?)
    case updateShouldNotify(Bool)
  }

  struct State {
    var type: EditType
    var reminder: Reminder
    var cachedReminder: Reminder?
  }

  // MARK: - Initializer

  /// type이 `.edit`일 경우 사용합니다.
  init(_ type: EditType = .edit, reminder: Reminder) {
    self.initialState = State(
      type: type,
      reminder: reminder,
      cachedReminder: reminder
    )
  }

  /// type이 `.new`일 경우 사용합니다.
  init(_ type: EditType = .new) {
    self.initialState = State(
      type: type,
      reminder: Reminder()
    )
  }

  // MARK: - Functions

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      return .merge(
        .just(.updateReminderDate(self.currentState.reminder.date)),
        .just(.updateNotifyTime(self.currentState.reminder.notifyDate))
      )

    case .doneButtonDidTap:
      os_log(.debug, "Done button did tap.")
      print(self.currentState.reminder)
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
      newState.reminder.date = date ?? .distantPast

    case .updateNotifyTime(let time):
      newState.reminder.notifyDate = time

    case .updateShouldNotify(let shouldNotify):
      newState.reminder.shouldNotify = shouldNotify
    }

    return newState
  }
}
