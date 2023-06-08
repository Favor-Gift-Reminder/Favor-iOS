//
//  EditMyPageViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/02/22.
//

import FavorKit
import FavorNetworkKit
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
  let userNetworking = UserNetworking()

  enum Action {
    case viewNeedsLoaded
    case cancelButtonDidTap
    case doneButtonDidTap(with: (String?, String?))
    case favorDidSelected(Int)
    case doNothing
  }

  enum Mutation {
    case updateFavor([EditMyPageSectionItem])
  }

  struct State {
    var user: User
    var sections: [EditMyPageSection] = []
    var items: [[EditMyPageSectionItem]] = []
    var nameItems: [EditMyPageSectionItem] = []
    var idItems: [EditMyPageSectionItem] = []
    var favorItems: [EditMyPageSectionItem] = []
  }

  // MARK: - Initializer

  init(user: User) {
    self.initialState = State(
      user: user,
      nameItems: [.textField(text: user.name, placeholder: "이름")],
      idItems: [.textField(text: user.searchID, placeholder: "ID")],
      favorItems: Favor.allCases.map { favor in
        return .favor(isSelected: user.favorList.contains(favor), favor: favor)
      }
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

    case let .doneButtonDidTap(with: (name, id)):
      let favors = currentState.favorItems.compactMap { item -> String? in
        guard
          case let EditMyPageSectionItem.favor(isSelected, favor) = item,
          isSelected
        else { return nil }
        return favor.rawValue
      }
      return self.userNetworking.request(.patchUser(
        name: name ?? currentState.user.name,
        userId: id ?? currentState.user.searchID,
        favorList: favors,
        userNo: UserInfoStorage.userNo
      ))
      .flatMap { _ -> Observable<Mutation> in
        self.steps.accept(AppStep.editMyPageIsComplete)
        return .empty()
      }

    case .favorDidSelected(let indexPath):
      var favorItems = self.currentState.favorItems
      guard
        indexPath < favorItems.count,
        case let EditMyPageSectionItem.favor(isSelected, favor) = favorItems[indexPath],
        favorItems.count == Constant.numberOfFavors
      else { return .empty() }

      // 이미 선택된 취향의 개수
      let selectedFavorsCount = favorItems.reduce(0) { count, favorItem in
        guard case let EditMyPageSectionItem.favor(isSelected, _) = favorItem else { return count }
        return isSelected ? count + 1 : count
      }
      // 선택된 취향의 개수가 5개 이상이고 선택된 Cell의 취향이 선택되지 않은 상태일 때 (5개 초과의 취향을 선택하고자 할 때)
      if selectedFavorsCount >= Constant.maximumSelectedFavor && !isSelected { return .empty() }

      favorItems[indexPath] = EditMyPageSectionItem.favor(isSelected: !isSelected, favor: favor)
      return .just(.updateFavor(favorItems))

    case .doNothing:
      return .empty()
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .updateFavor(let favorItems):
      newState.favorItems = favorItems
    }

    return newState
  }

  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { (state: State) -> State in
      var newState = state
      newState.sections = [.id, .name, .favor]
      newState.items = [state.nameItems, state.idItems, state.favorItems]
      return newState
    }
  }
}
