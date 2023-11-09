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
  private let fetcher = Fetcher<Gift>()
  private let workBench = RealmWorkbench()
  
  enum Action {
    case viewNeedsLoad
    case editButtonDidTap
    case deleteButtonDidTap
    case shareButtonDidTap
    case giftNeedsUpdated(Gift)
    case giftPhotoDidSelected(Int)
    case isPinnedButtonDidTap
    case emotionTagDidTap(FavorEmotion)
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
    self.setupFetcher(with: gift.identifier)
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewNeedsLoad:
      return self.fetcher.fetch()
        .compactMap { $0.results.first }
        .flatMap { return Observable<Mutation>.just(.updateGift($0)) }
      
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
      return self.requestToggleIsPinned(self.currentState.gift)
        .asObservable()
        .flatMap { gift -> Observable<Mutation> in
          if gift.isPinned {
            ToastManager.shared.showNewToast(.init(.custom("홈 타임라인에 고정되었습니다.")))
          }
          return .just(.updateGift(gift))
        }
        .catch { error in
          print(error)
          return .empty()
        }
      
    case .emotionTagDidTap(let emotion):
      self.steps.accept(AppStep.searchEmotionResultIsRequired(emotion))
      return .empty()

    case .categoryTagDidTap(let category):
      self.steps.accept(AppStep.searchCategoryResultIsRequired(category))
      return .empty()
      
    case .isGivenTagDidTap(let isGiven):
      // TODO: 타임라인 단독 화면 만든 후 연결
      os_log(.debug, "IsGiven tag did tap: \(isGiven).")
      return .empty()

    case .friendsTagDidTap(let friends):
      self.steps.accept(AppStep.giftDetailFriendsBottomSheetIsRequired(friends))
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
      
      let gift = state.gift
      let imageItems: [Item] = state.gift.photos.map { .image($0.remote) }
      newState.imageItems = imageItems
      newState.items = [imageItems, [.title(gift)], [.tags(gift)], [.memo(gift)]]

      return newState
    }
  }
}

// MARK: - Privates

private extension GiftDetailViewReactor {
  func setupFetcher(with identifier: Int) {
    // onRemote
    self.fetcher.onRemote = {
      let networking = GiftNetworking()
      let gift = networking.request(.getGift(giftNo: identifier))
        .flatMap { response -> Observable<[Gift]> in
          let responseDTO: ResponseDTO<GiftSingleResponseDTO> = try APIManager.decode(response.data)
          return .just([Gift(singleDTO: responseDTO.data)])
        }
        .asSingle()
      return gift
    }
    // onLocal
    self.fetcher.onLocal = {
      return await self.workBench.values(GiftObject.self)
        .filter { $0.giftNo == identifier } 
        .map { Gift(realmObject: $0) }
    }
    // onLocalUpdate
    self.fetcher.onLocalUpdate = { _, remoteGifts in
      try await self.workBench.write { transaction in
        transaction.update(remoteGifts.map { $0.realmObject() })
      }
    }
  }
  
  func requestDeleteGift(_ gift: Gift) -> Single<Gift> {
    return Single<Gift>.create { single in
      let networking = GiftNetworking()
      let disposable = networking.request(.deleteGift(giftNo: gift.identifier))
        .take(1)
        .asSingle()
        .subscribe(onSuccess: { response in
          do {
            let responseDTO: ResponseDTO<GiftSingleResponseDTO> = try APIManager.decode(response.data)
            single(.success(Gift(singleDTO: responseDTO.data)))
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
      let disposable = networking.request(.patchPinGift(giftNo: gift.identifier))
        .take(1)
        .asSingle()
        .subscribe(onSuccess: { response in
          do {
            let responseDTO: ResponseDTO<GiftSingleResponseDTO> = try APIManager.decode(response.data)
            single(.success(Gift(singleDTO: responseDTO.data)))
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
