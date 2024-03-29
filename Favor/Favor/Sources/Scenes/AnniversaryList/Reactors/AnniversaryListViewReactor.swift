//
//  AnniversaryListViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/05/16.
//

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
  let workbench = RealmWorkbench()
  
  enum Action {
    case viewNeedsLoaded
    case editButtonDidTap
    case rightButtonDidTap(Anniversary)
    case floatyButtonDidTap
  }
  
  enum Mutation {
    case updateAnniversaries([Anniversary])
    case updateAllSection([Item])
  }
  
  struct State {
    var anniversaries: [Anniversary] = []
    var sections: [Section] = []
    var items: [Item] = []
    var anniversaryListType: AnniversaryListType
  }
  
  // MARK: - Initializer
  
  init(_ type: AnniversaryListType) {
    self.initialState = State(anniversaryListType: type)
    super.init()
    
    if case AnniversaryListType.friend(let friend) = type {
      self.setupFriendFetcher(with: friend)
    }
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewNeedsLoaded:
      switch self.currentState.anniversaryListType {
      case .mine:
        return self.userFetcher.fetch()
          .flatMap { (_, user) -> Observable<Mutation> in
            guard let user = user.first else { return .empty() }
            let anniversaries = user.anniversaryList
            return .just(.updateAnniversaries(anniversaries))
          }
      case .friend:
        return self.friendFetcher.fetch()
          .flatMap { (_, friend) -> Observable<Mutation> in
            guard let friend = friend.first else { return .empty() }
            return .just(.updateAnniversaries(friend.anniversaryList))
          }
      }
      
    case .editButtonDidTap:
      self.steps.accept(AppStep.editAnniversaryListIsRequired(self.currentState.anniversaries))
      return .empty()
      
    case .rightButtonDidTap(let tappedAnniversary):
      switch self.currentState.anniversaryListType {
      case .mine:
        // 0. 고정되어 있는 기념일이 3개가 초과된 경우를 판별합니다.
        let originalPinnedAnniversaries = self.currentState.anniversaries.filter({ $0.isPinned })
        let isPinnedTargetAnniversary: Int = !tappedAnniversary.isPinned ? 1 : 0
        
        guard originalPinnedAnniversaries.count + isPinnedTargetAnniversary < 4 else {
          // 고정된 기념일이 3개 초과되었을 경우입니다.
          ToastManager.shared.showNewToast(.init(.anniversaryPinLimited))
          return .empty()
        }
        
        // 1. 현재 상태의 값을 백업
        let originalAnniversaries = self.currentState.anniversaries
        guard
          let originalTargetAnniversary = originalAnniversaries.first(where: { anniversary in
            anniversary == tappedAnniversary
          }),
          originalTargetAnniversary.isPinned == tappedAnniversary.isPinned
        else { return .empty() }
        
        // 2. UI 우선 업데이트 - `anniversary`의 데이터를 변경하여 우선 업데이트
        let newAnniversaries = originalAnniversaries.map { (originalAnniversary: Anniversary) in
          if originalAnniversary == tappedAnniversary {
            var anniversary = originalAnniversary
            anniversary.isPinned.toggle()
            return anniversary
          } else {
            return originalAnniversary
          }
        }
        
        // 3. 서버 통신 - 완료되면 `anniversary`의 데이터를 변경하여 업데이트
        return .concat(
          .just(.updateAnniversaries(newAnniversaries)),
          self.requestToggleAnniversaryPin(with: tappedAnniversary)
            .asObservable()
            .flatMap { anniversary -> Observable<Mutation> in
              if anniversary.isPinned {
                ToastManager.shared.showNewToast(.init(.anniversaryisPinned(true)))
              } else {
                ToastManager.shared.showNewToast(.init(.anniversaryisPinned(false)))
              }
              return .empty()
            }
            .catch { error -> Observable<Mutation> in
              os_log(.error, "🚨 Failure: \(error)")
              return .just(.updateAnniversaries(originalAnniversaries))
            }
        )
      case .friend(let friend):
        self.steps.accept(AppStep.newReminderIsRequiredWithAnniversary(tappedAnniversary, friend))
        return .empty()
      }
      
    case .floatyButtonDidTap:
      self.steps.accept(AppStep.newAnniversaryIsRequired)
      return .empty()
    }
  }
  
  func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
    return mutation.flatMap { originalMutation -> Observable<Mutation> in
      switch originalMutation {
      case .updateAnniversaries(let anniversaries):
        let sortedAnniversaries = anniversaries.sort()
          .map { $0.toItem(forSection: .all, isMine: self.currentState.anniversaryListType == .mine) }
        
        return .concat([
          .just(originalMutation),
          .just(.updateAllSection(sortedAnniversaries))
        ])
        
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

    case .updateAllSection(let allItems):
      newState.items = allItems
      
    }

    return newState
  }

  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state

      // 비어있을 때
      if state.items.isEmpty {
        newState.sections = [.empty]
        newState.items = [.empty]
        return newState
      }
      
      // 전체
      if !state.items.isEmpty {
        newState.sections.append(.all)
        newState.items = state.items
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
      
      return networking.request(.patchAnniversaryPin(anniversaryNo: anniversary.identifier))
        .asSingle()
        .map(ResponseDTO<AnniversarySingleResponseDTO>.self)
        .map { Anniversary(singleDTO: $0.data) }
        .subscribe(onSuccess: { anniversary in
          Task {
            try await self.workbench.write { transaction in
              transaction.update(anniversary.realmObject())
              DispatchQueue.main.async {
                single(.success(anniversary))
              }
            }
          }
        }, onFailure: { error in
          single(.failure(error))
        })
    }
  }
}

// MARK: - Anniversary Helper

extension Anniversary {
  fileprivate func toItem(
    forSection section: AnniversaryListSection,
    isMine: Bool
  ) -> AnniversaryListSectionItem {
    return .anniversary(isMine ? .list : .friend, anniversary: self, for: section)
  }
}
