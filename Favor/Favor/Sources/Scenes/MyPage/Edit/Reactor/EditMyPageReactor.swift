//
//  EditMyPageReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/02/22.
//

import ReactorKit
import RxCocoa
import RxFlow

final class EditMyPageReactor: Reactor, Stepper {

  // MARK: - Properties

  var initialState: State
  var steps = PublishRelay<Step>()

  enum Action {
    case viewDidLoad
  }

  enum Mutation {
    case updateDataSource
  }

  struct State {
    var sections: [SelectFavorSection] = []
  }

  // MARK: - Initializer

  init() {
    self.initialState = State()
  }


  // MARK: - Functions

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      return .just(.updateDataSource)
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .updateDataSource:
      newState.sections = self.setupMockSection()
    }

    return newState
  }
}

// MARK: - Temporaries

private extension EditMyPageReactor {
  func setupMockSection() -> [SelectFavorSection] {

    var items: [SelectFavorSection.Item] = []
    (0..<18).forEach { _ in
      items.append(FavorCellReactor())
    }
    let selectFavorSection = SelectFavorSection(header: "취향", items: items)

    return [selectFavorSection]
  }
}
