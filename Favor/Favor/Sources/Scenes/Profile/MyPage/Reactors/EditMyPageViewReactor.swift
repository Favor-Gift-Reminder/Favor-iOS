//
//  EditMyPageViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/02/22.
//

import ReactorKit
import RxCocoa
import RxFlow

final class EditMyPageViewReactor: Reactor, Stepper {

  // MARK: - Properties

  var initialState: State
  var steps = PublishRelay<Step>()

  enum Action {
    case viewDidLoad
  }

  enum Mutation {
    case updateFavorSelectionDataSource
    case updateNewAnniversaryDataSource
  }

  struct State {
    var favorSelectionSections: [FavorSelectionSection] = []
    var newAnniversarySections: [NewAnniversarySection] = []
  }

  // MARK: - Initializer

  init() {
    self.initialState = State()
  }


  // MARK: - Functions

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      return .concat([
        .just(.updateFavorSelectionDataSource),
        .just(.updateNewAnniversaryDataSource)
      ])
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .updateFavorSelectionDataSource:
      newState.favorSelectionSections = self.setupFavorSelectionMockSection()

    case .updateNewAnniversaryDataSource:
      newState.newAnniversarySections = []
    }

    return newState
  }
}

// MARK: - Temporaries

private extension EditMyPageViewReactor {
  func setupFavorSelectionMockSection() -> [FavorSelectionSection] {
    var items: [FavorSelectionSection.Item] = []
    (0 ..< 18).forEach { _ in
      items.append(ProfilePreferenceCellReactor(preference: "귀여운"))
    }
    let favorSelectionSection = FavorSelectionSection(header: "취향", items: items)

    return [favorSelectionSection]
  }
}
