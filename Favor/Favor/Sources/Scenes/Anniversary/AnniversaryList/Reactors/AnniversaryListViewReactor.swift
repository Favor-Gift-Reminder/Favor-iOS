//
//  AnniversaryListViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/05/16.
//

import OSLog

import FavorKit
import FavorNetworkKit
import ReactorKit
import RxCocoa
import RxFlow

final class AnniversaryListViewReactor: BaseAnniversaryListViewReactor, Reactor, Stepper {
  typealias Section = AnniversaryListSection
  typealias Item = AnniversaryListSectionItem

  // MARK: - Properties

  var initialState: State
  var steps = PublishRelay<Step>()

  enum Action {
    case viewNeedsLoaded
    case editButtonDidTap
    case rightButtonDidTap(Anniversary)
  }

  enum Mutation {
    case updateAnniversaries([Anniversary])
    case updatePinnedSection([Item])
    case updateAllSection([Item])
  }

  struct State {
    var anniversaries: [Anniversary] = []
    var sections: [Section] = []
    var items: [[Item]] = []
    var pinnedItems: [Item] = []
    var allItems: [Item] = []
  }

  // MARK: - Initializer

  override init() {
    self.initialState = State()
    super.init()
  }

  // MARK: - Functions

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewNeedsLoaded:
      return self.userFetcher.fetch()
        .flatMap { (state, user) -> Observable<Mutation> in
          guard let user = user.first else { return .empty() }
          let anniversaries = user.anniversaryList.toArray()
          return .just(.updateAnniversaries(anniversaries))
        }

    case .editButtonDidTap:
      self.steps.accept(AppStep.editAnniversaryListIsRequired(self.currentState.anniversaries))
      return .empty()

    case .rightButtonDidTap(let anniversary):
      print(anniversary)
      return .empty()
    }
  }

  func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
    return mutation.flatMap { originalMutation -> Observable<Mutation> in
      switch originalMutation {
      case .updateAnniversaries(let anniversaries):
        let (pinnedItems: pinnedItems, allItems: allItems) = anniversaries
          .reduce(into: (pinnedItems: [Item](), allItems: [Item]())) { result, anniversary in
            // 고정됨 부분과 전체 부분의 값이 같더라도 cell의 reactor는 달라야하기 때문에
            // 각각 생성해줍니다.
            result.allItems.append(anniversary.toItem(cellType: .list))
            if anniversary.isPinned {
              result.pinnedItems.append(anniversary.toItem(cellType: .list))
            }
          }
        return .concat(
          .just(originalMutation),
          .just(.updatePinnedSection(pinnedItems)),
          .just(.updateAllSection(allItems))
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

      // 비어있을 때
      if state.allItems.isEmpty {
        newState.sections = [.empty]
        newState.items = [[.empty]]
        return newState
      }

      // 고정됨
      if !state.pinnedItems.isEmpty {
        newState.sections = [.pinned]
        newState.items = [state.pinnedItems]
      }
      // 전체
      if !state.allItems.isEmpty {
        newState.sections.append(.all)
        newState.items.append(state.allItems)
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
