//
//  GiftManagementViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/05/29.
//

import UIKit

import FavorKit
import FavorNetworkKit
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
    case doneButtonDidTap
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
    var viewType: GiftManagementViewController.ViewType
    var giftType: GiftManagementViewController.GiftType = .received
    var gift: GiftEditor
//    let giftNo: Int
//    var title: String?
//    var category: FavorCategory = .lightGift
//    var photos: [UIImage] = []
//    var date: Date?
//    var memo: String?
//    var isPinned: Bool = false

    var sections: [Section] = [.title, .category, .photos, .friends(isGiven: false), .date, .memo, .pin]
    var items: [[Item]] = []
  }

  // MARK: - Initializer

  init(_ viewType: GiftManagementViewController.ViewType, pickerManager: PHPickerManager) {
    self.initialState = State(
      viewType: viewType,
      gift: GiftEditor()
    )
    self.pickerManager = pickerManager
  }

  init(_ viewType: GiftManagementViewController.ViewType, with gift: Gift, pickerManager: PHPickerManager) {
    self.initialState = State(
      viewType: viewType,
      gift: gift.toDomain()
    )
    self.pickerManager = pickerManager
  }

  // MARK: - Functions

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .cancelButtonDidTap:
      self.steps.accept(AppStep.giftManagementIsComplete)
      return .empty()

    case .doneButtonDidTap:
      switch self.currentState.viewType {
      case .new:
        return self.requestPostGift(self.currentState.gift)
          .asObservable()
          .flatMap { gift -> Observable<Mutation> in
            return .empty()
          }
      case .edit:
        return .empty()
      }

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
      if let index = newState.sections.firstIndex(of: .friends(isGiven: !isGiven)) {
        let newFriendsSection: Section = .friends(isGiven: isGiven)
        newState.sections[index] = newFriendsSection
      }
      newState.giftType = isGiven ? .given : .received

    case .updateTitle(let title):
      newState.gift.name = title ?? ""

    case .updateCategory(let category):
      newState.gift.category = category

    case .updatePhotos(let photos):
      newState.gift.photoList = photos

    case .updateIsPinned(let isPinned):
      newState.gift.isPinned = isPinned
    }

    return newState
  }

  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state

      var photoItems: [Item] = state.gift.photoList.map { .photo($0) }
      photoItems.insert(.photo(nil), at: .zero)
      newState.items = [
        [.title], [.category], photoItems, [.friends], [.date], [.memo], [.pin]
      ]

      return newState
    }
  }
}

// MARK: - Privates

private extension GiftManagementViewReactor {
  func requestPostGift(_ gift: GiftEditor) -> Single<Gift> {
    return Single<Gift>.create { single in
      let networking = GiftNetworking()
      let requestDTO = GiftRequestDTO(
        giftName: gift.name,
        giftDate: gift.date?.toDTODateString() ?? Date.distantPast.toDTODateString(),
        giftMemo: gift.memo ?? "",
        category: gift.category.rawValue,
        emotion: gift.emotion ?? "기뻐요",
        isPinned: gift.isPinned,
        isGiven: gift.isGiven,
        friendNoList: gift.friendList.map { $0.friendNo }
      )

      let disposable = networking.request(.postGift(requestDTO, userNo: UserInfoStorage.userNo))
        .asSingle()
        .subscribe(with: self, onSuccess: { _, response in
          do {
            let responseDTO: ResponseDTO<GiftResponseDTO> = try APIManager.decode(response.data)
            single(.success(responseDTO.data.toDomain()))
          } catch {
            single(.failure(error))
          }
        })

      return Disposables.create {
        disposable.dispose()
      }
    }
  }

  func requestPatchGift(_ gift: Gift) -> Single<Gift> {
    return Single<Gift>.create { single in
      let networking = GiftNetworking()
      let requestDTO = GiftUpdateRequestDTO(
        giftName: gift.name,
        giftDate: gift.date?.toDTODateString() ?? Date.distantPast.toDTODateString(),
        giftMemo: gift.memo ?? "",
        category: gift.category.rawValue,
        emotion: gift.emotion ?? "기뻐요",
        isPinned: gift.isPinned,
        isGiven: gift.isGiven,
        friendNoList: gift.friendList.toArray().map { $0.friendNo }
      )

      let disposable = networking.request(.patchGift(requestDTO, giftNo: gift.giftNo))
        .asSingle()
        .subscribe(with: self, onSuccess: { _, response in
          do {
            let responseDTO: ResponseDTO<GiftResponseDTO> = try APIManager.decode(response.data)
            single(.success(responseDTO.data.toDomain()))
          } catch {
            single(.failure(error))
          }
        })

      return Disposables.create {
        disposable.dispose()
      }
    }
  }
}
