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

  enum Action {
    case editButtonDidTap
    case deleteButtonDidTap
    case cancelButtonDidTap
    case doneButtonDidTap
  }

  enum Mutation {
    case switchEditModeTo(Bool)
  }

  struct State {
    var isEditable: Bool = false
  }

  // MARK: - Initializer

  init() {
    self.initialState = State()
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
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .switchEditModeTo(let isEditable):
      newState.isEditable = isEditable
    }

    return newState
  }
}
