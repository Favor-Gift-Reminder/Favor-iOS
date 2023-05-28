//
//  GiftDetailViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/05/25.
//

import FavorKit
import ReactorKit
import RxCocoa
import RxFlow

final class GiftDetailViewReactor: Reactor, Stepper {
  typealias Item = GiftDetailSectionItem

  // MARK: - Properties

  var initialState: State
  var steps = PublishRelay<Step>()

  enum Action {
    case editButtonDidTap
    case deleteButtonDidTap
    case shareButtonDidTap
    case giftPhotoDidSelected(Int)
    case isPinnedButtonDidTap
    case doNothing
  }

  enum Mutation {

  }

  struct State {
    var gift: Gift
    var items: [[Item]] = []
    var imageItems: [Item] = []
  }

  // MARK: - Initializer

  init(gift: Gift) {
    self.initialState = State(
      gift: gift
    )
  }

  // MARK: - Functions

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .editButtonDidTap:
      return .empty()

    case .deleteButtonDidTap:
      return .empty()

    case .shareButtonDidTap:
      return .empty()

    case .giftPhotoDidSelected(let item):
      let total = self.currentState.gift.photoList.count
      self.steps.accept(AppStep.giftDetailPhotoIsRequired(item, total))
      return .empty()

    case .isPinnedButtonDidTap:
      print("Pinned button did tap.")
      return .empty()

    case .doNothing:
      return .empty()
    }
  }

  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state

      if state.gift.photoList.toArray().isEmpty {
        newState.imageItems = [.image(nil), .image(.favorIcon(.add)), .image(.favorIcon(.addFriend)), .image(.favorIcon(.addNoti))]
      } else {
        newState.imageItems = [.image(nil), .image(.favorIcon(.add)), .image(.favorIcon(.addFriend)), .image(.favorIcon(.addNoti))]
      }
      newState.items = [newState.imageItems, [.title], [.tags], [.memo]]

      return newState
    }
  }
}
