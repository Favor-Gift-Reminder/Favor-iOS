//
//  SearchTagViewReactor.swift
//  Favor
//
//  Created by 이창준 on 6/15/23.
//

import FavorKit
import FavorNetworkKit
import ReactorKit
import RxCocoa
import RxFlow

public final class SearchTagViewReactor: Reactor, Stepper {

  // MARK: - Properties

  public var initialState: State
  public var steps = PublishRelay<Step>()
  private let workbench = RealmWorkbench()
  private let giftFetcher = Fetcher<Gift>()

  public enum Action {
    case viewNeedsLoaded
    case categoryDidSelected(FavorCategory)
    case emotionDidSelected(FavorEmotion)
  }

  public enum Mutation {
    case updateSelectedCategory(FavorCategory)
    case updateSelectedEmotion(FavorEmotion)
    case updateGifts([Gift])
  }

  public struct State {
    var category: FavorCategory?
    var emotion: FavorEmotion?
    var sections: [SearchTagSection] = []
    var gifts: [Gift] = []
    var giftItems: [SearchTagSectionItem] = []
  }

  // MARK: - Initializer

  init() {
    self.initialState = State()
  }

  // MARK: - Functions

  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewNeedsLoaded:
      return .empty()

    case .categoryDidSelected(let category):
      self.setupFetcher(with: category)
      return .concat(
        .just(.updateSelectedCategory(category)),
        self.giftFetcher.fetch()
          .asObservable()
          .flatMap { gifts -> Observable<Mutation> in
            return .just(.updateGifts(gifts.results))
          }
      )

    case .emotionDidSelected(let emotion):
      self.setupFetcher(with: emotion)
      return .concat(
        .just(.updateSelectedEmotion(emotion)),
        self.giftFetcher.fetch()
          .asObservable()
          .flatMap { gifts -> Observable<Mutation> in
            return .just(.updateGifts(gifts.results))
          }
      )
    }
  }

  public func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .updateSelectedCategory(let category):
      newState.category = category

    case .updateSelectedEmotion(let emotion):
      newState.emotion = emotion

    case .updateGifts(let gifts):
      newState.gifts = gifts
    }

    return newState
  }

  public func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state

      if state.gifts.isEmpty {
        newState.sections = [.empty]
        newState.giftItems = [.empty(nil, "검색 결과가 없습니다.")]
      } else {
        newState.sections = [.gift]
        newState.giftItems = state.gifts.map { .gift($0) }
      }

      return newState
    }
  }
}

// MARK: - Fetcher

private extension SearchTagViewReactor {
  func setupFetcher(with category: FavorCategory) {
    // onRemote
    self.giftFetcher.onRemote = {
      let networking = UserNetworking()
      let gifts = networking.request(.getGiftByCategory(category: category.rawValue))
        .flatMap { response -> Observable<[Gift]> in
          let responseDTO: ResponseDTO<[GiftResponseDTO]> = try APIManager.decode(response.data)
          return .just(responseDTO.data.map { Gift(dto: $0) })
        }
        .asSingle()
      return gifts
    }
    // onLocal
    self.giftFetcher.onLocal = {
      return await self.workbench.values(GiftObject.self)
        .filter { $0.category == category }
        .map { Gift(realmObject: $0) }
    }
    // onLocalUpdate
    self.giftFetcher.onLocalUpdate = { _, remoteGifts in
      try await self.workbench.write { transaction in
        transaction.update(remoteGifts.map { $00.realmObject() })
      }
    }
  }

  func setupFetcher(with emotion: FavorEmotion) {
    // onRemote
    self.giftFetcher.onRemote = {
      let networking = UserNetworking()
      let gifts = networking.request(.getGiftByEmotion(emotion: emotion.rawValue))
        .flatMap { response -> Observable<[Gift]> in
          let responseDTO: ResponseDTO<[GiftResponseDTO]> = try APIManager.decode(response.data)
          return .just(responseDTO.data.map { Gift(dto: $0) })
        }
        .asSingle()
      return gifts
    }
    // onLocal
    self.giftFetcher.onLocal = {
      return await self.workbench.values(GiftObject.self)
        .filter { $0.emotion == emotion }
        .map { Gift(realmObject: $0) }
    }
    // onLocalUpdate
    self.giftFetcher.onLocalUpdate = { _, remoteGifts in
      try await self.workbench.write { transaction in
        transaction.update(remoteGifts.map { $00.realmObject() })
      }
    }
  }
}
