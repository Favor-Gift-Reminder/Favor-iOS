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
  private let workbench = RealmWorkbench()
  private let reminderFetcher = Fetcher<Reminder>()
  private let giftFetcher = Fetcher<Gift>()
  
  // Global State
  let currentSortType = BehaviorRelay<SortType>(value: .latest)
  
  enum Action {
    case viewNeedsLoaded
    case didChangeSortType(SortType)
    case searchButtonDidTap
    case rightButtonDidTap(HomeSection)
    case filterButtonDidSelected(GiftFilterType)
    case updateMaxTimelineItems((current: Int, unit: Int))
    case itemSelected(Item)
    case timelineNeedsLoaded(Bool)
    case switchDidTap(Item)
    case reminderDidEdit(Reminder)
  }
  
  enum Mutation {
    case popNewToast(String)
    case updateReminders([Reminder])
    case updateUpcomingSection([Item])
    case updateGifts([Gift])
    case updateTimelineSection([Item])
    case updateMaxTimelineItems((current: Int, unit: Int))
    case updateFilterType(GiftFilterType)
    case updateLoading(Bool)
    case updateTimelineLoading(Bool)
    case updateSortType(SortType)
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
    var maxTimelineItems: (current: Int, unit: Int) = (current: 10, unit: 10)
    var currentSortType: SortType

    var filterType: GiftFilterType = .all
    var isLoading: Bool = false
    var isTimelineLoading: Bool = false
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
      switch FTUXStorage.authState {
      case .undefined:
        os_log(.info, "ℹ️ Skipping home view configuration since AuthState is not defined.")
        return .empty()
      default:
        let fetchedDatas: Observable<(reminders: [Reminder], gifts: [Gift])> = .zip(
          self.reminderFetcher.fetch(),
          self.giftFetcher.fetch(),
          resultSelector: { reminderResult, giftResult -> ([Reminder], [Gift]) in
            return (reminderResult.results, giftResult.results)
          })
        return fetchedDatas
          .flatMap { fetchData -> Observable<Mutation> in
            let reminders = fetchData.reminders
            let gifts = fetchData.gifts
            return .concat([
              .just(.updateReminders(reminders)),
              .just(.updateGifts(gifts)),
              .just(.updateTimelineLoading(false))
            ])
          }
      }
      
    case .searchButtonDidTap:
      os_log(.debug, "Search button did tap.")
      self.steps.accept(AppStep.searchIsRequired)
      return .empty()
      
    case .rightButtonDidTap(let section):
      if case Section.upcoming = section {
        self.steps.accept(AppStep.reminderIsRequired)
      }
      return .empty()

    case .filterButtonDidSelected(let filterType):
      return .just(.updateFilterType(filterType))

    case let .updateMaxTimelineItems((currentMaxItems, unit)):
      return .just(.updateMaxTimelineItems((current: currentMaxItems, unit: unit)))
      
    case .itemSelected(let item):
      if case let Item.upcoming(upcoming) = item {
        guard case let Item.Upcoming.reminder(reminder) = upcoming else { return .empty() }
        self.steps.accept(AppStep.reminderDetailIsRequired(reminder))
      } else if case let Item.timeline(timeline) = item {
        guard case let Item.Timeline.gift(gift) = timeline else { return .empty() }
        self.steps.accept(AppStep.giftDetailIsRequired(gift))
      }
      return .empty()

    case .timelineNeedsLoaded(let isLoading):
      return .just(.updateTimelineLoading(isLoading))
      
    case .didChangeSortType(let sortType):
      return .just(.updateSortType(sortType))
      
    case .switchDidTap(let item):
      if case let Item.upcoming(.reminder(reminder)) = item {
        self.toggleReminderAlarm(reminder)
      }
      return .empty()
      
    case .reminderDidEdit(let reminder):
      var newReminders = self.currentState.reminders
      guard let firstIndex = newReminders
        .firstIndex(where: { $0.identifier == reminder.identifier })
      else { return .empty() }
      newReminders[firstIndex] = reminder
      return .just(.updateReminders(newReminders))
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

    case let .updateMaxTimelineItems((maxItems, unit)):
      newState.maxTimelineItems = (current: maxItems, unit: unit)

    case .updateFilterType(let filterType):
      newState.filterType = filterType

    case .updateLoading(let isLoading):
      newState.isLoading = isLoading

    case .updateTimelineLoading(let isLoading):
      newState.isTimelineLoading = isLoading
      
    case .updateSortType(let sortType):
      newState.currentSortType = sortType
    }
    
    return newState
  }
  
  // transform(state:)는 State stream에 영향을 주지 않습니다.
  // 단지 View에 최종적으로 전달되는 State에 변형을 줄 뿐입니다. = 저장되어있는 State는 변하지 않습니다.
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      
      // Upcoming 데이터를 조건에 따라 Item으로 변환합니다.
      let (futureReminders, _) = state.reminders.sort()
      let upcomingThreeReminders: [Reminder] = futureReminders.prefix(3).wrap()
      let upcomingItems: [Item] = upcomingThreeReminders.map { .upcoming(.reminder($0)) }
      // Upcoming이 비어있을 경우 .empty 데이터 추가
      newState.sections.append(.upcoming(isEmpty: upcomingItems.isEmpty))
      if upcomingItems.isEmpty {
        newState.upcomingItems = [.upcoming(.empty(nil, "이벤트가 없습니다."))]
      } else {
        newState.upcomingItems = upcomingItems
      }
      
      // Timeline 데이터를 조건에 따라 Item으로 변환합니다.
      let filteredGifts = state.gifts.filter(by: state.filterType)
      let (pinnedGifts, unpinnedGifts) = filteredGifts.sort(by: .isPinned)
      var pinnedTimelines: [Item] = pinnedGifts.map { .timeline(.gift($0)) }
      var unpinnedTimelines: [Item] = unpinnedGifts.map { .timeline(.gift($0)) }
      
      if self.currentState.currentSortType == .latest {
        pinnedTimelines.reverse()
        unpinnedTimelines.reverse()
      }
      
      let totalTimelines: [Item] = pinnedTimelines + unpinnedTimelines
      // Load 최대 개수 만큼만 반환
      let croppedTimelines = totalTimelines.prefix(self.currentState.maxTimelineItems.current).wrap()
      // Timeline이 비어있을 경우 .empty 데이터 추가
      newState.sections.append(.timeline(isEmpty: croppedTimelines.isEmpty))
      if croppedTimelines.isEmpty {
        newState.timelineItems = [.timeline(.empty(nil, "선물 기록이 없습니다."))]
      } else {
        newState.timelineItems = croppedTimelines
      }
      
      newState.items = [newState.upcomingItems, newState.timelineItems]

      return newState
    }
  }
}

// MARK: - Network

private extension HomeViewReactor {
  func setupReminderFetcher() {
    // onRemote
    self.reminderFetcher.onRemote = {
      let networking = UserNetworking()
      let reminders = networking.request(.getAllReminderList)
        .flatMap { response -> Observable<[Reminder]> in
          let responseDTO: ResponseDTO<[ReminderResponseDTO]> = try APIManager.decode(response.data)
          return .just(responseDTO.data.map { Reminder(dto: $0) })
        }
        .catch { error in
          if let error = error as? APIError {
            os_log(.error, "\(error.description)")
          }
          return .error(error)
        }
        .asSingle()
      return reminders
    }
    // onLocal
    self.reminderFetcher.onLocal = {
      return await self.workbench.values(ReminderObject.self)
        .map { Reminder(realmObject: $0) }
    }
    // onLocalUpdate
    self.reminderFetcher.onLocalUpdate = { localReminders, remoteReminders in
      let deleteReminders = localReminders.filter { localReminder in
        !remoteReminders.map { $0.identifier }.contains(localReminder.identifier)
      }
      try await self.workbench.write { transaction in
        deleteReminders.forEach { transaction.delete($0.realmObject()) }
        transaction.update(remoteReminders.map { $0.realmObject() })
      }
    }
  }
  
  func setupGiftFetcher() {
    // onRemote
    self.giftFetcher.onRemote = {
      let networking = UserNetworking()
      let gifts = networking.request(.getAllGifts)
        .flatMap { response -> Observable<[Gift]> in
          let responseDTO: ResponseDTO<[GiftResponseDTO]> = try APIManager.decode(response.data)
          return .just(responseDTO.data.map { Gift(dto: $0) })
        }
        .catch { error in
          if let error = error as? APIError {
            os_log(.error, "\(error.description)")
          }
          return .error(error)
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
  
  func toggleReminderAlarm(_ reminder: Reminder) {
    let networking = ReminderNetworking()
    _ = networking.request(.patchReminder(reminder.toggleAlarmSet(), reminderNo: reminder.identifier))
      .map(ResponseDTO<ReminderSingleResponseDTO>.self)
      .map { Reminder(singleDTO: $0.data) }
      .subscribe(onNext: { newReminder in
        ReminderAlertManager.shared.reminderDidEdit(newReminder)
        self.action.onNext(.reminderDidEdit(newReminder))
        Task {
          try await self.workbench.write { transaction in
            transaction.update(newReminder.realmObject())
          }
        }
      })
  }
}
