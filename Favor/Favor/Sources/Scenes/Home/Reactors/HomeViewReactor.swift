//
//  HomeViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2022/12/30.
//

import OSLog
import UIKit

import FavorKit
import FavorNetworkKit
import ReactorKit
import RealmSwift
import RxCocoa
import RxFlow

final class HomeViewReactor: Reactor, Stepper {
  typealias Section = HomeSection
  typealias Item = HomeSectionItem
  
  // MARK: - Properties
  
  var initialState: State
  var steps = PublishRelay<Step>()
  let reminderFetcher = Fetcher<Reminder>()
  let giftFetcher = Fetcher<Gift>()

  // Global State
  let currentSortType = BehaviorRelay<SortType>(value: .latest)
  
  enum Action {
    case viewNeedsLoaded
    case searchButtonDidTap
    case itemSelected(IndexPath)
  }
  
  enum Mutation {
    case popNewToast(String)
    case updateReminders([Reminder])
    case updateUpcomingSection([Item])
    case updateGifts([Gift])
    case updateTimelineSection([Item])
    case updateLoading(Bool)
  }
  
  struct State {
    @Pulse var toastMessage: String?
    var sections: [Section] = []
    var items: [[Item]] = []

    // Upcoming
    var reminders: [Reminder] = []
    var upcomingItems: [Item] = []

    // Timeline
    var gifts: [Gift] = []
    var timelineItems: [Item] = []
    var maxTimelineItems: Int = 10
    var currentSortType: SortType

    var isLoading: Bool = false
  }
  
  // MARK: - Initializer
  
  init() {
    self.initialState = State(
      currentSortType: self.currentSortType.value
    )
    self.setupReminderFetcher()
    self.setupGiftFetcher()
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewNeedsLoaded:
      let fetchedDatas: Observable<(reminders: [Reminder], gifts: [Gift])> = .zip(
        self.reminderFetcher.fetch(),
        self.giftFetcher.fetch(),
        resultSelector: { reminderResult, giftResult -> ([Reminder], [Gift]) in
          return (reminderResult.results.toArray(), giftResult.results.toArray())
        })
      return fetchedDatas.flatMap { fetchedData -> Observable<Mutation> in
        let reminders = fetchedData.reminders
        let gifts = fetchedData.gifts
        return .concat([
          .just(.updateReminders(reminders)),
          .just(.updateGifts(gifts))
//          .just(.updateLoading(true))
        ])
      }

    case .searchButtonDidTap:
      os_log(.debug, "Search button did tap.")
      self.steps.accept(AppStep.searchIsRequired)
      return .empty()

    case .itemSelected:
      return .empty()
    }
  }

  func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
    return mutation.flatMap { originalMutation -> Observable<Mutation> in
      switch originalMutation {
      case .updateReminders(let reminders):
        let (futureReminders, _) = reminders.sort()
        let upcomingThreeReminders: [Reminder] = futureReminders.prefix(3).wrap()
        let upcomings: [Item] = upcomingThreeReminders.map { .upcoming(.reminder($0)) }
        return .concat(
          .just(originalMutation),
          .just(.updateUpcomingSection(upcomings))
        )
      case .updateGifts(let gifts):
        let (pinnedGifts, unpinnedGifts) = gifts.sort(by: .isPinned)
        let pinnedTimelines: [Item] = pinnedGifts.map { .timeline(.gift($0)) }
        let unpinnedTimelines: [Item] = unpinnedGifts.map { .timeline(.gift($0)) }

        let croppedTimelines = (pinnedTimelines + unpinnedTimelines)
          .prefix(self.currentState.maxTimelineItems)
          .wrap()
        return .concat(
          .just(originalMutation),
          .just(.updateTimelineSection(croppedTimelines))
        )
      default:
        return .just(originalMutation)
      }
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .popNewToast(let message):
      newState.toastMessage = message

    case .updateReminders(let reminders):
      newState.reminders = reminders

    case .updateUpcomingSection(let items):
      newState.upcomingItems = items

    case .updateGifts(let gifts):
      newState.gifts = gifts

    case .updateTimelineSection(let items):
      newState.timelineItems = items

    case .updateLoading(let isLoading):
      newState.isLoading = isLoading
    }

    return newState
  }

  // transform(state:)는 State stream에 영향을 주지 않습니다.
  // 단지 View에 최종적으로 전달되는 State에 변형을 줄 뿐입니다. = 저장되어있는 State는 변하지 않습니다.
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state

      // Upcoming이 비어있을 경우 .empty 데이터 추가
      newState.sections.append(.upcoming(isEmpty: state.upcomingItems.isEmpty))
      if state.upcomingItems.isEmpty {
        newState.upcomingItems = [.upcoming(.empty(nil, "이벤트가 없습니다."))]
      }
      // Timeline이 비어있을 경우 .empty 데이터 추가
      newState.sections.append(.timeline(isEmpty: state.timelineItems.isEmpty))
      if state.timelineItems.isEmpty {
        newState.timelineItems = [.timeline(.empty(nil, "선물 기록이 없습니다."))]
      }
      newState.items = [newState.upcomingItems, newState.timelineItems]

      return newState
    }
  }
}

// MARK: - Fetcher

private extension HomeViewReactor {
  func setupReminderFetcher() {
    // onRemote
    self.reminderFetcher.onRemote = {
      let networking = UserNetworking()
      let reminders = networking.request(.getAllReminderList(userNo: UserInfoStorage.userNo))
        .flatMap { response -> Observable<[Reminder]> in
          let responseDTO: ResponseDTO<[ReminderResponseDTO]> = try APIManager.decode(response.data)
          return .just(responseDTO.data.map { $0.toDomain() })
        }
        .asSingle()
      return reminders
    }
    // onLocal
    self.reminderFetcher.onLocal = {
      return try await RealmManager.shared.read(Reminder.self)
    }
    // onLocalUpdate
    self.reminderFetcher.onLocalUpdate = { _, remoteReminders in
      try await RealmManager.shared.updateAll(remoteReminders, update: .all)
    }
  }

  func setupGiftFetcher() {
    // onRemote
    self.giftFetcher.onRemote = {
      let networking = UserNetworking()
      let gifts = networking.request(.getAllGifts(userNo: UserInfoStorage.userNo))
        .flatMap { response -> Observable<[Gift]> in
          let responseDTO: ResponseDTO<[GiftResponseDTO]> = try APIManager.decode(response.data)
          return .just(responseDTO.data.map { $0.toDomain() })
        }
        .asSingle()
      return gifts
    }
    // onLocal
    self.giftFetcher.onLocal = {
      return try await RealmManager.shared.read(Gift.self)
    }
    // onLocalUpdate
    self.giftFetcher.onLocalUpdate = { _, remoteGifts in
      try await RealmManager.shared.updateAll(remoteGifts, update: .all)
    }
  }
}
