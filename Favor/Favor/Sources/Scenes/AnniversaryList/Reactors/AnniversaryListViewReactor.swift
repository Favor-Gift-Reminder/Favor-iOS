//
//  AnniversaryListViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/05/16.
//

import OrderedCollections

import FavorKit
import FavorNetworkKit
import ReactorKit

final class AnniversaryListViewReactor: Reactor {
  typealias Section = AnniversaryListSection
  typealias Item = AnniversaryListSectionItem

  // MARK: - Properties

  var initialState: State

  enum Action {
    case viewNeedsLoaded
  }

  enum Mutation {
    case updatePinnedSection([Item])
    case updateAllSection([Item])
  }

  struct State {
    var viewState: AnniversaryListViewController.ViewState = .list
    var anniversaries: [Anniversary] = []
    var sections: [Section] = []
    var items: [[Item]] = []
    var pinnedItems: [Item] = []
    var allItems: [Item] = []
  }

  // MARK: - Initializer

  init() {
    self.initialState = State()
  }

  // MARK: - Functions

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewNeedsLoaded:
      return .empty()
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .updatePinnedSection(let pinnedItems):
      newState.pinnedItems = pinnedItems

    case .updateAllSection(let allItems):
      newState.allItems = allItems
    }

    return newState
  }

  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state

      // 고정
      if !state.pinnedItems.isEmpty {
        guard !state.allItems.isEmpty else { fatalError() }
        newState.sections.append(.pinned)
        newState.items.append(state.pinnedItems)
      }

      // 전체
      if !state.allItems.isEmpty {
        newState.sections.append(.all)
        newState.items.append(state.allItems)
      } else { // Empty
        newState.sections.append(.empty)
        newState.items.append([.empty])
      }

      return newState
    }
  }
}
