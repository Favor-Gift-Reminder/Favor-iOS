//
//  GiftManagementViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/05/29.
//

import UIKit

import FavorKit
import ReactorKit
import RxCocoa
import RxFlow

final class GiftManagementViewReactor: Reactor, Stepper {
  typealias Section = GiftManagementSection
  typealias Item = GiftManagementSectionItem

  // MARK: - Properties

  var initialState: State
  var steps = PublishRelay<Step>()
  let pickerManager: PHPickerManager

  enum Action {
    case cancelButtonDidTap
    case giftTypeButtonDidTap(isGiven: Bool)
    case itemSelected(IndexPath)
    case titleDidUpdate(String?)
    case categoryDidUpdate(FavorCategory)
    case photoDidSelected(Item)
    case friendsSelectorButtonDidTap
    case pinButtonDidTap(Bool)
    case doNothing
  }

  enum Mutation {
    case updateGiftType(isGiven: Bool)
    case updateTitle(String?)
    case updateCategory(FavorCategory)
    case updatePhotos([UIImage])
    case updateIsPinned(Bool)
  }

  struct State {
    var giftType: GiftManagementViewController.GiftType = .received
    var gift: Gift?
    var category: FavorCategory = .lightGift
    var title: String?
    var photos: [UIImage] = []
    var isPinned: Bool = false

    var sections: [Section] = [.title, .category, .photos, .friends, .date, .memo, .pin]
    var items: [[Item]] = []
  }

  // MARK: - Initializer

  init(pickerManager: PHPickerManager) {
    self.initialState = State()
    self.pickerManager = pickerManager
  }

  init(with gift: Gift, pickerManager: PHPickerManager) {
    self.initialState = State(
      gift: gift,
//      category: gift.category, // TODO: Category 프로퍼티 enum화
      title: gift.name,
//      photos: gift.photoList.toArray(),
      isPinned: gift.isPinned
    )
    self.pickerManager = pickerManager
  }

  // MARK: - Functions

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .cancelButtonDidTap:
      self.steps.accept(AppStep.giftManagementIsComplete)
      return .empty()

    case .giftTypeButtonDidTap(let isGiven):
      return .just(.updateGiftType(isGiven: isGiven))

    case .itemSelected(let indexPath):
      return .empty()

    case .titleDidUpdate(let title):
      return .just(.updateTitle(title))

    case .categoryDidUpdate(let category):
      return .just(.updateCategory(category))

    case .photoDidSelected(let item):
      if
        case Item.photo(let image) = item,
        image == nil {
        self.steps.accept(AppStep.imagePickerIsRequired(self.pickerManager))
      }
      return .empty()

    case .friendsSelectorButtonDidTap:
      self.steps.accept(AppStep.newGiftFriendIsRequired)
      return .empty()

    case .pinButtonDidTap(let isPinned):
      return .just(.updateIsPinned(isPinned))

    case .doNothing:
      return .empty()
    }
  }

  func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
    let updatePickedContents = self.pickerManager.pickedContents
      .flatMap { images -> Observable<Mutation> in
        return .just(.updatePhotos(images))
      }
    return .merge(mutation, updatePickedContents)
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .updateGiftType(let isGiven):
      newState.giftType = isGiven ? .given : .received

    case .updateTitle(let title):
      newState.title = title

    case .updateCategory(let category):
      newState.category = category

    case .updatePhotos(let photos):
      newState.photos = photos

    case .updateIsPinned(let isPinned):
      newState.isPinned = isPinned
    }

    return newState
  }

  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state

      var photoItems: [Item] = state.photos.map { .photo($0) }
      photoItems.insert(.photo(nil), at: .zero)
      newState.items = [
        [.title], [.category], photoItems, [.friends], [.date], [.memo], [.pin]
      ]

      return newState
    }
  }
}
