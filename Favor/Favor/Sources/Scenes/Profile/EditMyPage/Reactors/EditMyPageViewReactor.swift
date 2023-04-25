//
//  EditMyPageViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/02/22.
//

import FavorKit
import ReactorKit
import RxCocoa
import RxFlow

final class EditMyPageViewReactor: Reactor, Stepper {

  // MARK: - Properties

  var initialState: State
  var steps = PublishRelay<Step>()

  enum Action {
    case viewNeedsLoaded
  }

  enum Mutation {

  }

  struct State {
    var preferenceSection: [EditMyPagePreferenceSection] = [
      EditMyPagePreferenceSection(
        header: "취향",
        items: Favor.allCases.map { EditMyPagePreferenceCellReactor(favor: $0.rawValue) }
      )
    ]
  }

  // MARK: - Initializer

  init(user: User) {
    self.initialState = State()
  }


  // MARK: - Functions

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewNeedsLoaded:
      return .empty()
    }
  }
}
