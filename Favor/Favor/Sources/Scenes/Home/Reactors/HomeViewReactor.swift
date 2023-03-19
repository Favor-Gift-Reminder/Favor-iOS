//
//  HomeViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2022/12/30.
//

import OSLog
import UIKit

import FavorKit
import ReactorKit
import RxCocoa
import RxFlow

final class HomeViewReactor: Reactor, Stepper {
  
  // MARK: - Properties
  
  var initialState: State
  var steps = PublishRelay<Step>()

  // Global State
  let currentSortType = BehaviorRelay<SortType>(value: .latest)
  
  enum Action {
    case viewDidLoad
    case searchButtonDidTap
    case newGiftButtonDidTap
    case itemSelected(IndexPath)
    case rightButtonDidTap(HomeSectionType)
  }
  
  enum Mutation {
    case popNewToast(String)
    case updateUpcoming(HomeSection.HomeSectionModel)
    case updateTimeline(HomeSection.HomeSectionModel)
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
  }
  
  // MARK: - Initializer
  
  init() {
    self.initialState = State(
      currentSortType: self.currentSortType.value
    )
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      return .concat([
        .just(.updateUpcoming(self.fetchUpcoming())),
        .just(.updateTimeline(self.fetchTimeline()))
      ])

    case .searchButtonDidTap:
      os_log(.debug, "Search button did tap.")
      return .empty()

    case .newGiftButtonDidTap:
      os_log(.debug, "New Gift button did tap.")
      return .empty()

    case .itemSelected:
      return .empty()

    case .rightButtonDidTap(let sectionType):
      switch sectionType {
      case .upcoming: break
      case .timeline:
        self.steps.accept(AppStep.filterIsRequired(self.currentSortType.value))
      }
      return .empty()
    }
  }

  func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
    return .merge(mutation)
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

private extension HomeViewReactor {
  func fetchUpcoming() -> HomeSection.HomeSectionModel {
    let upcomingItems = self.getUpcomingMock().map {
      let reactor = UpcomingCellReactor(cellData: $0)
      return HomeSection.HomeSectionItem.upcoming(reactor)
    }
    return HomeSection.HomeSectionModel(
      model: .upcoming,
      items: upcomingItems
    )
  }

  func fetchTimeline() -> HomeSection.HomeSectionModel {
    let timelineItems = getTimelineMock().map {
      let reactor = TimelineCellReactor(cellData: $0)
      return HomeSection.HomeSectionItem.timeline(reactor)
    }
    return HomeSection.HomeSectionModel(
      model: .timeline,
      items: timelineItems
    )
  }

  func getUpcomingMock() -> [CardCellData] {
    return (1...2).map {
      CardCellData(
        iconImage: UIImage(named: "p\($0)"),
        title: "기념일 \($0)",
        subtitle: "2023. 03. 0\($0)"
      )
    }
//    return []
  }

  func getTimelineMock() -> [TimelineCellData] {
    return (1...3).map {
      TimelineCellData(image: UIImage(named: "d\($0)"), isPinned: false)
    }
//    return []
  }
}
