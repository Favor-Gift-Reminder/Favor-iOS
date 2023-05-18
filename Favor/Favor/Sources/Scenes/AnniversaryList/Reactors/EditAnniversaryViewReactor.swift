//
//  EditAnniversaryViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/05/18.
//

import OSLog

import FavorKit
import ReactorKit
import RxCocoa
import RxFlow

final class EditAnniversaryViewReactor: Reactor, Stepper {
  typealias Section = EditAnniversarySection
  typealias Item = EditAnniversarySectionItem

  // MARK: - Properties

  var initialState: State
  var steps = PublishRelay<Step>()

  enum Action {
    case doneButtonDidTap
    case nameDidUpdate(String?)
    case deleteButtonDidTap
  }

  enum Mutation {

  }

  struct State {
    var anniversary: Anniversary
    var sections: [Section] = [.name, .category, .date]
    var items: [Item] = [.name, .category, .date]
  }

  // MARK: - Initializer

  init(with anniversary: Anniversary) {
    self.initialState = State(
      anniversary: anniversary
    )
  }

  // MARK: - Functions

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .doneButtonDidTap:
      os_log(.debug, "Done button did tap.")
      return .empty()

    case .nameDidUpdate(let name):
      os_log(.debug, "Name did update to: \(String(describing: name))")
      return .empty()

    case .deleteButtonDidTap:
      os_log(.debug, "Delete button did tap.")
      return .empty()
    }
  }
}
