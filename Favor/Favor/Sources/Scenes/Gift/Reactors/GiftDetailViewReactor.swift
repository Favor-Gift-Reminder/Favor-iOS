//
//  GiftDetailViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/05/25.
//

import OSLog

import FavorKit
import FavorNetworkKit
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
    case giftNeedsUpdated(Gift)
    case giftPhotoDidSelected(Int)
    case isPinnedButtonDidTap
    case emotionTagDidTap
    case categoryTagDidTap(FavorCategory)
    case isGivenTagDidTap(Bool)
    case friendsTagDidTap([Friend])
    case doNothing
  }

  enum Mutation {
    case updateGift(Gift)
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
      self.steps.accept(AppStep.giftManagementIsRequired(self.currentState.gift))
      return .empty()

    case .deleteButtonDidTap:
      return self.requestDeleteGift(self.currentState.gift)
        .asObservable()
        .flatMap { gift -> Observable<Mutation> in
          self.steps.accept(AppStep.giftDetailIsComplete(gift))
          return .empty()
        }

    case .shareButtonDidTap:
      self.steps.accept(AppStep.giftShareIsRequired(self.currentState.gift))
      return .empty()

    case .giftNeedsUpdated(let gift):
      return .just(.updateGift(gift))

    case .giftPhotoDidSelected(let item):
      let total = self.currentState.gift.photos.count 
      self.steps.accept(AppStep.giftDetailPhotoIsRequired(item, total))
      return .empty()

    case .isPinnedButtonDidTap:
      var updatedGift = self.currentState.gift
      updatedGift.isPinned.toggle()
      return self.requestToggleIsPinned(updatedGift)
        .asObservable()
        .flatMap { gift -> Observable<Mutation> in
          return .just(.updateGift(gift))
        }
        .catch { error in
          print(error)
          return .empty()
        }

    case .emotionTagDidTap:
      os_log(.debug, "Emotion tag did tap.")
      return .empty()

    case .categoryTagDidTap(let category):
      os_log(.debug, "Category tag did tap: \(String(describing: category)).")
      return .empty()

    case .isGivenTagDidTap(let isGiven):
      os_log(.debug, "IsGiven tag did tap: \(isGiven).")
      return .empty()

    case .friendsTagDidTap(let friends):
      os_log(.debug, "Friends tag did tap: \(String(describing: friends)).")
      return .empty()

    case .doNothing:
      return .empty()
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .updateGift(let gift):
      newState.gift = gift
    }

    return newState
  }

  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state

      if state.gift.photos.count == .zero {
        newState.imageItems = [.image(nil), .image(.favorIcon(.add)), .image(.favorIcon(.addFriend)), .image(.favorIcon(.addNoti))]
      } else {
        newState.imageItems = [.image(nil), .image(.favorIcon(.add)), .image(.favorIcon(.addFriend)), .image(.favorIcon(.addNoti))]
      }
      newState.items = [newState.imageItems, [.title], [.tags], [.memo]]

      return newState
    }
  }
}

// MARK: - Privates

private extension GiftDetailViewReactor {
  func requestDeleteGift(_ gift: Gift) -> Single<Gift> {
    return Single<Gift>.create { single in
      let networking = GiftNetworking()
      let disposable = networking.request(.deleteGift(giftNo: gift.identifier))
        .take(1)
        .asSingle()
        .subscribe(onSuccess: { response in
          do {
            let responseDTO: ResponseDTO<GiftResponseDTO> = try APIManager.decode(response.data)
            single(.success(Gift(dto: responseDTO.data)))
          } catch {
            single(.failure(error))
          }
        }, onFailure: { error in
          single(.failure(error))
        })

      return Disposables.create {
        disposable.dispose()
      }
    }
  }

  func requestToggleIsPinned(_ gift: Gift) -> Single<Gift> {
    return Single<Gift>.create { single in
      let networking = GiftNetworking()
      let disposable = networking.request(.patchGift(gift.updateRequestDTO(), giftNo: gift.identifier))
        .take(1)
        .asSingle()
        .subscribe(onSuccess: { response in
          do {
            let responseDTO: ResponseDTO<GiftResponseDTO> = try APIManager.decode(response.data)
            single(.success(Gift(dto: responseDTO.data)))
          } catch {
            single(.failure(error))
          }
        }, onFailure: { error in
          single(.failure(error))
        })

      return Disposables.create {
        disposable.dispose()
      }
    }
  }
}
