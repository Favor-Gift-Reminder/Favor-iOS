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
  
  enum ViewType {
    case category(FavorCategory)
    case emotion(FavorEmotion)
  }

  // MARK: - Properties

  public var initialState: State
  public var steps = PublishRelay<Step>()
  private let workbench = RealmWorkbench()
  private let giftFetcher = Fetcher<Gift>()
  
  public enum Action {
    case viewNeedsLoaded
    case categoryDidSelected(FavorCategory)
    case emotionDidSelected(FavorEmotion)
    case itemSelected(SearchTagSectionItem)
  }
  
  public enum Mutation {
    case updateSelectedCategory(FavorCategory)
    case updateSelectedEmotion(FavorEmotion)
    case updateGifts([Gift])
  }
  
  public struct State {
    var viewType: ViewType
    var category: FavorCategory = .graduation
    var emotion: FavorEmotion = .xoxo
    var sections: [SearchTagSection] = []
    var gifts: [Gift] = []
    var giftItems: [SearchTagSectionItem] = []
  }

  // MARK: - Initializer

  init(_ viewType: ViewType) {
    switch viewType {
    case .category(let favorCategory):
      self.initialState = State(viewType: viewType, category: favorCategory)
    case .emotion(let favorEmotion):
      self.initialState = State(viewType: viewType, emotion: favorEmotion)
    }
    self.setupFetcher()
  }

  // MARK: - Functions
  
  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewNeedsLoaded:
      return self.giftFetcher.fetch()
        .asObservable()
        .flatMap { gifts -> Observable<Mutation> in
          return .just(.updateGifts(gifts.results))
        }
      
    case .categoryDidSelected(let category):
      return .just(.updateSelectedCategory(category))
      
    case .emotionDidSelected(let emotion):
      return .just(.updateSelectedEmotion(emotion))
      
    case .itemSelected(let item):
      switch item {
      case .gift(let gift):
        self.steps.accept(AppStep.giftDetailIsRequired(gift))
        return .empty()
      default:
        return .empty()
      }
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
        switch state.viewType {
        case .category:
          newState.giftItems = state.gifts
            .filter { $0.category == state.category }
            .map { .gift($0) }
        case .emotion:
          newState.giftItems = state.gifts
            .filter { $0.emotion == state.emotion }
            .map { .gift($0) }
        }
      }

      return newState
    }
  }
}

// MARK: - Fetcher

private extension SearchTagViewReactor {
  func setupFetcher() {
    let viewType = self.currentState.viewType
    // onRemote
    self.giftFetcher.onRemote = {
      let networking = GiftNetworking()
      let gifts = networking.request(.getAllGifts)
        .map(ResponseDTO<[GiftSingleResponseDTO]>.self)
        .map { $0.data.filter { $0.userNo == UserInfoStorage.userNo } }
        .map { $0.map { Gift(singleDTO: $0) } }
        .flatMap { gifts -> Observable<[Gift]> in
          return .just(gifts)
        }
        .asSingle()
      return gifts
    }
    // onLocal
    self.giftFetcher.onLocal = {
      return await self.workbench.values(GiftObject.self)
        .map { Gift(realmObject: $0) }
    }
    // onLocalUpdate
    self.giftFetcher.onLocalUpdate = { localGifts, remoteGifts in
      // 삭제시킬 선물을 찾습니다.
      let deleteGifts = localGifts.filter { localGift in
        !remoteGifts.map { $0.identifier }.contains(localGift.identifier)
      }
      try await self.workbench.write { transaction in
        deleteGifts.forEach { transaction.delete($0.realmObject()) }
        transaction.update(remoteGifts.map { $0.realmObject() })
      }
    }
  }
}
