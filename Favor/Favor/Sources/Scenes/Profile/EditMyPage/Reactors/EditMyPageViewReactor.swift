//
//  EditMyPageViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/02/22.
//

import OrderedCollections

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
    case favorDidSelected(Int)
  }

  enum Mutation {
    case updateSelectedFavors(OrderedDictionary<Favor, Bool>)
    case updateFavor(EditMyPageSection)
  }

  struct State {
    var sections: [EditMyPageSection] = []
    var nameSection: EditMyPageSection = .name([.textField(placeholder: "이름")])
    var idSection: EditMyPageSection = .id([.textField(placeholder: "아이디")])
    var favorSection: EditMyPageSection = .favor([])
    var selectedFavors: OrderedDictionary<Favor, Bool> = [:]
  }

  // MARK: - Initializer

  init(user: User) {
    self.initialState = State()
  }


  // MARK: - Functions

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewNeedsLoaded:
      let selectedFavors: OrderedDictionary<Favor, Bool> = Favor.allCases.reduce(into: [:]) { result, favor in
        result[favor] = false
      }
      return .just(.updateSelectedFavors(selectedFavors))

    case .favorDidSelected(let indexPath):
      var newSelectedFavors = self.currentState.selectedFavors
      let count = newSelectedFavors.reduce(0) { count, dict in
        if dict.value {
          return count + 1
        } else {
          return count
        }
      }
      if count >= 5 && newSelectedFavors.values[indexPath] == false {
        return .empty()
      } else {
        newSelectedFavors.values[indexPath].toggle()
        return .just(.updateSelectedFavors(newSelectedFavors))
      }
    }
  }

  func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
    return mutation.flatMap { mutation -> Observable<Mutation> in
      if case let Mutation.updateSelectedFavors(newSelectedFavors) = mutation {
        return .concat(
          .just(.updateSelectedFavors(newSelectedFavors)),
          .just(.updateFavor(self.refinePreference(selectedFavors: newSelectedFavors)))
        )
      } else {
        return .just(mutation)
      }
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .updateSelectedFavors(let favorDictionary):
      newState.selectedFavors = favorDictionary

    case .updateFavor(let favorSection):
      newState.favorSection = favorSection
    }

    return newState
  }

  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { (state: State) -> State in
      var newState = state
      newState.sections = [state.nameSection, state.idSection, state.favorSection]
      return newState
    }
  }
}

// MARK: - Privates

private extension EditMyPageViewReactor {
  func refinePreference(selectedFavors: OrderedDictionary<Favor, Bool>) -> EditMyPageSection {
    let favorItem = selectedFavors.map { selectedFavor -> EditMyPageSectionItem in
      let reactor = EditMyPagePreferenceCellReactor(
        favor: selectedFavor.key,
        isSelected: selectedFavor.value
      )
      return .favor(reactor)
    }
    return .favor(favorItem)
  }
}
