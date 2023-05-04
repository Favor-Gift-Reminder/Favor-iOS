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

  // MARK: - Constants

  private enum Constant {
    static let numberOfFavors = 18
    static let maximumSelectedFavor = 5
  }

  // MARK: - Properties

  var initialState: State
  var steps = PublishRelay<Step>()

  enum Action {
    case viewNeedsLoaded
    case cancelButtonDidTap
    case doneButtonDidTap
    case nameDidUpdate(String?)
    case idDidUpdate(String?)
    case favorDidSelected(Int)
    case doNothing
  }

  enum Mutation {
    case updateName(String?)
    case updateID(String?)
    case updateFavor([EditMyPageSectionItem])
  }

  struct State {
    var user: User
    var sections: [EditMyPageSection] = []
    var nameSection: EditMyPageSection = .name([.name(placeholder: "이름")])
    var name: String?
    var idSection: EditMyPageSection = .id([.id(placeholder: "아이디")])
    var id: String?
    var favorSection: EditMyPageSection = .favor([])
  }

  // MARK: - Initializer

  init(user: User) {
    self.initialState = State(
      user: user,
      favorSection: .favor(Favor.allCases.map { favor in
        return .favor(false, favor)
      })
    )
  }


  // MARK: - Functions

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewNeedsLoaded:
      return .empty()

    case .cancelButtonDidTap:
      self.steps.accept(AppStep.editMyPageIsComplete)
      return .empty()

    case .doneButtonDidTap:
      return .empty()

    case .nameDidUpdate(let name):
      return .just(.updateName(name))

    case .idDidUpdate(let id):
      return .just(.updateID(id))

    case .favorDidSelected(let indexPath):
      var favorItems = self.currentState.favorSection.items
      guard
        case let EditMyPageSectionItem.favor(isSelected, favor) = favorItems[indexPath],
        self.currentState.favorSection.items.count == Constant.numberOfFavors,
        indexPath < favorItems.count
      else { return .empty() }

      // 이미 선택된 취향의 개수
      let count = favorItems.filter { item in
        guard case let EditMyPageSectionItem.favor(isSelected, _) = item else { return false }
        return isSelected
      }.count
      // 선택된 취향의 개수가 5개 이상이고 선택된 Cell의 취향이 선택되지 않은 상태일 때 (5개 초과의 취향을 선택하고자 할 때)
      if count >= Constant.maximumSelectedFavor && !isSelected {
        return .empty()
      }

      favorItems[indexPath] = .favor(!isSelected, favor)
      return .just(.updateFavor(favorItems))

    case .doNothing:
      return .empty()
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .updateName(let name):
      newState.name = name

    case .updateID(let id):
      newState.id = id

    case .updateFavor(let favorItems):
      newState.favorSection = .favor(favorItems)
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
