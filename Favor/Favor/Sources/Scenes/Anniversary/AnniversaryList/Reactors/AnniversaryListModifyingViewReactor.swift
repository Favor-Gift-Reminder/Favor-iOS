//
//  AnniversaryListModifyingViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/05/17.
//

import FavorKit
import FavorNetworkKit
import ReactorKit
import RxCocoa
import RxFlow

final class AnniversaryListModifyingViewReactor: BaseAnniversaryListViewReactor, Reactor, Stepper {
  typealias Section = AnniversaryListSection
  typealias Item = AnniversaryListSectionItem

  // MARK: - Properties

  var initialState: State
  var steps = PublishRelay<Step>()

  enum Action {
    case viewNeedsLoaded
    case newButtonDidTap
    case editButtonDidTap(Anniversary)
  }

  enum Mutation {
    case updateAnniversaries([Anniversary])
    case updateItems([Item])
  }

  struct State {
    var anniversaries: [Anniversary]
    var section: Section = .empty
    var items: [Item] = []
  }

  // MARK: - Initializer

  init(with anniversaries: [Anniversary]) {
    self.initialState = State(
      anniversaries: anniversaries
    )
    super.init()
  }

  // MARK: - Functions

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewNeedsLoaded:
      return self.userFetcher.fetch()
        .flatMap { (status, user) -> Observable<Mutation> in
          guard let user = user.toArray().first else { return .empty() }
          return .just(.updateAnniversaries(user.anniversaryList.toArray()))
        }

    case .newButtonDidTap:
      self.steps.accept(AppStep.newAnniversaryIsRequired)
      return .empty()

    case .editButtonDidTap(let anniversary):
      self.steps.accept(AppStep.editAnniversaryIsRequired(anniversary))
      return .empty()
    }
  }

  func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
    return mutation.flatMap { originalMutation -> Observable<Mutation> in
      switch originalMutation {
      case .updateAnniversaries(let anniversaries):
        return .concat(
          .just(originalMutation),
          .just(.updateItems(anniversaries.map { $0.toItem(cellType: .edit) }))
        )
      default:
        return .just(originalMutation)
      }
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .updateAnniversaries(let anniversaries):
      newState.anniversaries = anniversaries

    case .updateItems(let items):
      newState.items = items
    }

    return newState
  }

  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state

      if state.items.isEmpty {
        newState.section = .empty
        newState.items = [.empty]
      } else {
        newState.section = .edit
      }

      return newState
    }
  }
}

// MARK: - Anniversary Helper

extension Anniversary {
  fileprivate func toItem(
    cellType: AnniversaryListCell.CellType
  ) -> AnniversaryListSectionItem {
    return .anniversary(AnniversaryListCellReactor(cellType: cellType, anniversary: self))
  }
}
