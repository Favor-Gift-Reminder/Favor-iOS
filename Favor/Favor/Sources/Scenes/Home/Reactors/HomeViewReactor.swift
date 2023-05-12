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
import RxCocoa
import RxFlow

/*
 Fetcher가 fetch하는 시점
 - 뷰가 시작될 때 (viewDidLoad)
*/

final class HomeViewReactor: Reactor, Stepper {
  
  // MARK: - Properties
  
  var initialState: State
  var steps = PublishRelay<Step>()
  let reminderFetcher = Fetcher<[Reminder]>()

  // Global State
  let currentSortType = BehaviorRelay<SortType>(value: .latest)
  
  enum Action {
    case viewNeedsLoaded
    case searchButtonDidTap
    case itemSelected(IndexPath)
    case rightButtonDidTap(HomeSectionType)
  }
  
  enum Mutation {
    case popNewToast(String)
    case updateUpcoming(HomeSection.HomeSectionModel)
    case updateTimeline(HomeSection.HomeSectionModel)
    case updateLoading(Bool)
  }
  
  struct State {
    @Pulse var toastMessage: String?
    var upcomingSection = HomeSection.HomeSectionModel(
      model: .upcoming,
      items: []
    )
    var timelineSection = HomeSection.HomeSectionModel(
      model: .timeline,
      items: []
    )
    var currentSortType: SortType
    var isLoading: Bool = false
  }
  
  // MARK: - Initializer
  
  init() {
    self.initialState = State(
      currentSortType: self.currentSortType.value
    )
    self.setupReminderFetcher()
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewNeedsLoaded:
      return .empty()
//      return self.reminderFetcher.fetch()
//        .flatMap { (status, reminders) -> Observable<Mutation> in
//          let upcomingSection = self.refineUpcoming(reminders: reminders.prefix(3).wrap())
//          return .concat([
//            .just(.updateUpcoming(upcomingSection)),
//            .just(.updateLoading(status == .inProgress))
//          ])
//        }
    case .searchButtonDidTap:
      os_log(.debug, "Search button did tap.")
      self.steps.accept(AppStep.searchIsRequired)
      return .empty()

    case .itemSelected:
      return .empty()
      
    case .rightButtonDidTap(let sectionType):
      let type = "\(sectionType)"
      os_log(.debug, "\(type)")
      switch sectionType {
      case .upcoming:
        self.steps.accept(AppStep.reminderIsRequired)
      case .timeline:
        self.steps.accept(AppStep.filterIsRequired(self.currentSortType.value))
      }
      return .empty()
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .popNewToast(let message):
      newState.toastMessage = message

    case .updateUpcoming(let model):
      newState.upcomingSection = model
      
    case .updateTimeline(let model):
      newState.timelineSection = model

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
      if state.upcomingSection.items.isEmpty {
        newState.upcomingSection.items.append(.empty(nil, "이벤트가 없습니다."))
      }
      // Timeline이 비어있을 경우 .empty 데이터 추가
      if state.timelineSection.items.isEmpty {
        newState.timelineSection.items.append(.empty(nil, "선물 기록이 없습니다."))
      }
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
        .flatMap { reminders -> Observable<[Reminder]> in
          let responseData = reminders.data
          do {
            let decodedRemote: ResponseDTO<[ReminderResponseDTO]> = try APIManager.decode(responseData)
            return .just(decodedRemote.data.map {
              Reminder(
                reminderNo: $0.reminderNo,
                title: $0.reminderTitle,
                date: $0.reminderDate,
                shouldNotify: $0.isAlarmSet,
                friendNo: $0.friendNo
              )
            })
          } catch let error as APIError {
            os_log(.error, "\(error.description)")
            return .just([])
          }
        }
        .asSingle()
      return reminders
    }
    // onLocal
    self.reminderFetcher.onLocal = {
      let reminders = try await RealmManager.shared.read(Reminder.self)
      return await reminders.toArray()
    }
    // onLocalUpdate
    self.reminderFetcher.onLocalUpdate = { _, remoteReminders in
      os_log(.debug, "💽 ♻️ LocalDB REFRESH: \(remoteReminders)")
      try await RealmManager.shared.updateAll(remoteReminders)
    }
  }
}

// MARK: - Privates

private extension HomeViewReactor {
  func refineUpcoming(reminders: [Reminder]) -> HomeSection.HomeSectionModel {
    let upcomingItems = reminders.map {
      let reactor = UpcomingCellReactor(reminder: $0)
      return HomeSection.HomeSectionItem.upcoming(reactor)
    }
    return HomeSection.HomeSectionModel(
      model: .upcoming,
      items: upcomingItems
    )
  }

  func refineTimeline(gifts: [Gift]) -> HomeSection.HomeSectionModel {
    let timelineItems = gifts.map {
      let reactor = TimelineCellReactor(gift: $0)
      return HomeSection.HomeSectionItem.timeline(reactor)
    }
    return HomeSection.HomeSectionModel(
      model: .timeline,
      items: timelineItems
    )
  }
}
