//
//  ReminderViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/03/29.
//

import Foundation
import OSLog

import FavorKit
import ReactorKit
import RxCocoa
import RxFlow

final class ReminderViewReactor: Reactor, Stepper {

  // MARK: - Properties

  var initialState: State
  var steps = PublishRelay<Step>()

  enum Action {
    case selectDateButtonDidTap
  }

  enum Mutation {

  }

  struct State {
    var selectedDate: DateComponents = DateComponents(
      year: Int(Date().toYearString()),
      month: Int(Date().toMonthString())
    )
  }

  // MARK: - Initializer

  init() {
    self.initialState = State()
  }


  // MARK: - Functions

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .selectDateButtonDidTap:
      os_log(.debug, "Select date button did tap.")
      return .empty()
    }
  }
}
