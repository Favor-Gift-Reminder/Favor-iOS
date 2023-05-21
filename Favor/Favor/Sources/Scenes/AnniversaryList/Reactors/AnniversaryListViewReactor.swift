//
//  AnniversaryListViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/05/16.
//

import OrderedCollections
import OSLog

import FavorKit
import FavorNetworkKit
import ReactorKit
import RxCocoa
import RxFlow

final class AnniversaryListViewReactor: BaseAnniversaryListViewReactor, Reactor, Stepper {
  typealias Section = AnniversaryListSection
  typealias Item = AnniversaryListSectionItem

  // MARK: - Properties

  var initialState: State
  var steps = PublishRelay<Step>()
  let networking = AnniversaryNetworking()

  enum Action {
    case viewNeedsLoaded
    case editButtonDidTap
    case rightButtonDidTap(Anniversary)
  }

  enum Mutation {
    case updateAnniversaries([Anniversary])
    case updatePinnedSection([Item])
    case updateAllSection([Item])
  }

  struct State {
    var anniversaries: [Anniversary] = []
    var model: OrderedDictionary<Section, [Item]> = [:]
    var sections: [Section] = []
    var items: [[Item]] = []
    var pinnedItems: [Item] = []
    var allItems: [Item] = []
  }

  // MARK: - Initializer

  override init() {
    self.initialState = State()
    super.init()
  }

  // MARK: - Functions

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewNeedsLoaded:
      return self.userFetcher.fetch()
        .flatMap { (state, user) -> Observable<Mutation> in
          guard let user = user.first else { return .empty() }
          let anniversaries = user.anniversaryList.toArray()
          return .just(.updateAnniversaries(anniversaries))
        }

    case .editButtonDidTap:
      self.steps.accept(AppStep.editAnniversaryListIsRequired(self.currentState.anniversaries))
      return .empty()

    case .rightButtonDidTap(let anniversary):
      // 1. 현재 상태의 값을 백업
      let originalAnniversaries = self.currentState.anniversaries
      // 2. UI 우선 업데이트 - `anniversary`의 데이터를 변경하여 우선 업데이트
      let newAnniversaries = originalAnniversaries.map { (originalAnniversary: Anniversary) in
        let updatedAnniversary = Anniversary(
          anniversaryNo: originalAnniversary.anniversaryNo,
          title: originalAnniversary.title,
          date: originalAnniversary.date,
          isPinned: !originalAnniversary.isPinned
        )
        return originalAnniversary == anniversary ? updatedAnniversary : originalAnniversary
      }
      // 3. 서버 통신 - 완료되면 `anniversary`의 데이터를 변경하여 업데이트
      return .concat([
        .just(.updateAnniversaries(newAnniversaries)),
        self.requestToggleAnniversaryPin(with: anniversary)
          .asObservable()
          .flatMap { _ -> Observable<Mutation> in
            return .empty()
          }
          .catch { error -> Observable<Mutation> in
            print(error)
            return .just(.updateAnniversaries(originalAnniversaries))
          }
      ])
    }
  }

  func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
    return mutation.flatMap { originalMutation -> Observable<Mutation> in
      switch originalMutation {
      case .updateAnniversaries(let anniversaries):
        let (pinnedItems: pinnedItems, allItems: allItems) = anniversaries.sort()
          .reduce(into: (pinnedItems: [Item](), allItems: [Item]())) { result, anniversary in
            // 고정됨 부분과 전체 부분의 값이 같더라도 cell의 reactor는 달라야하기 때문에
            // 각각 생성해줍니다.
            result.allItems.append(anniversary.toItem(forSection: .all))
            if anniversary.isPinned {
              result.pinnedItems.append(anniversary.toItem(forSection: .pinned))
            }
          }
        return .concat(
          .just(originalMutation),
          .just(.updatePinnedSection(pinnedItems)),
          .just(.updateAllSection(allItems))
        )
      default:
        return .just(originalMutation)
      }
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .updateAnniversaries(let anniversaries):
      newState.anniversaries = anniversaries

    case .updatePinnedSection(let pinnedItems):
      newState.pinnedItems = pinnedItems

    case .updateAllSection(let allItems):
      newState.allItems = allItems
    }

    return newState
  }

  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state

      // 비어있을 때
      if state.allItems.isEmpty {
        newState.sections = [.empty]
        newState.items = [[.empty]]
        return newState
      }

      // 고정됨
      if !state.pinnedItems.isEmpty {
        newState.sections = [.pinned]
        newState.items = [state.pinnedItems]
      }
      // 전체
      if !state.allItems.isEmpty {
        newState.sections.append(.all)
        newState.items.append(state.allItems)
      }

      return newState
    }
  }
}

// MARK: - Privates

private extension AnniversaryListViewReactor {
  func requestToggleAnniversaryPin(with anniversary: Anniversary) -> Single<Anniversary> {
    return Single<Anniversary>.create { single in
      let networking = AnniversaryNetworking()
      let requestDTO = AnniversaryUpdateRequestDTO(
        anniversaryTitle: anniversary.title,
        anniversaryDate: anniversary.date.toDTODateString(),
        isPinned: !anniversary.isPinned
      )

      let disposable = networking.request(.patchAnniversary(requestDTO, anniversaryNo: anniversary.anniversaryNo))
        .asSingle()
        .subscribe(onSuccess: { response in
          do {
            let responseDTO: ResponseDTO<AnniversaryResponseDTO> = try APIManager.decode(response.data)
            let anniversary = responseDTO.data.toDomain()
            single(.success(anniversary))
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

// MARK: - Anniversary Helper

extension Anniversary {
  fileprivate func toItem(forSection section: AnniversaryListSection) -> AnniversaryListSectionItem {
    return .anniversary(.list, anniversary: self, for: section)
  }
}
