//
//  EditMyPageViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/02/22.
//

/*
 Known Bugs: -
 취향을 오른쪽으로 스크롤 한 상태에서 선택하면 Layout이 재정렬되는 문제
  - Section Items를 다시 정의하기 때문으로 추정
 TextField를 편집한 뒤 취향을 선택하면 text가 초기값으로 되돌아가는 문제
  - Section이 reload 되거나
  - 새로운 section으로 교체된다.
 -> 둘 다 동일한 형태의 문제로 보임
  - Section에 있는 값이 통째로 reload되거나 값 자체가 재정의 되고 있음
 */

import FavorKit
import FavorNetworkKit
import ReactorKit
import RxCocoa
import RxFlow

final class EditMyPageViewReactor: Reactor, Stepper {
  private typealias Item = EditMyPageSectionItem

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
    var nameSection: EditMyPageSection = .name([])
    var idSection: EditMyPageSection = .id([])
    var favorSection: EditMyPageSection = .favor([])
  }

  // MARK: - Initializer

  init(user: User) {
    self.initialState = State(
      user: user,
      nameSection: .name([.textField(text: user.name, placeholder: "이름")]),
      idSection: .id([.textField(text: user.userID, placeholder: "ID")]),
      favorSection: .favor(Favor.allCases.map { favor in
        return .favor(isSelected: false, favor: favor)
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

    case let .doneButtonDidTap(with: (name, id)):
      let favors = currentState.favorSection.items.compactMap { item -> String? in
        guard
          case let EditMyPageSectionItem.favor(isSelected, favor) = item,
          isSelected
        else { return nil }
        return favor.rawValue
      }
      return self.userNetworking.request(.patchUser(
        name: name ?? currentState.user.name,
        userId: id ?? currentState.user.userID,
        favorList: favors,
        userNo: UserInfoStorage.userNo
      ))
      .flatMap { _ -> Observable<Mutation> in
        return .empty()
      }

    case .favorDidSelected(let indexPath):
      guard
        var favorItems = self.currentState.favorSection.items as? [EditMyPageSectionItem],
        case let EditMyPageSectionItem.favor(isSelected, favor) = favorItems[indexPath],
        favorItems.count == Constant.numberOfFavors,
        indexPath < favorItems.count
      else { return .empty() }
      let favorItem = favorItems[indexPath]

      // 이미 선택된 취향의 개수
      let selectedFavorsCount = favorItems.filter { item in
        return isSelected
      }.count
      // 선택된 취향의 개수가 5개 이상이고 선택된 Cell의 취향이 선택되지 않은 상태일 때 (5개 초과의 취향을 선택하고자 할 때)
      if selectedFavorsCount >= Constant.maximumSelectedFavor && !isSelected {
        return .empty()
      }

      favorItems[indexPath] = Item.favor(isSelected: !isSelected, favor: favor)
      return .just(.updateFavor(favorItems))

    case .doNothing:
      return .empty()
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .updateFavor(let favorItems):
      newState.favorSection = EditMyPageSection.favor(favorItems)
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
