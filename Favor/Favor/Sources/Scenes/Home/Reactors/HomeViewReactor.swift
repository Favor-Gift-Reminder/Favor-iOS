//
//  HomeViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2022/12/30.
//

import OSLog
import UIKit

import ReactorKit
import RxCocoa
import RxFlow

final class HomeViewReactor: Reactor, Stepper {
  
  // MARK: - Properties
  
  var initialState: State
  var steps = PublishRelay<Step>()
  
  enum Action {
    case viewDidLoad
    case searchButtonDidTap
    case newGiftButtonDidTap
    case itemSelected(IndexPath)
  }
  
  enum Mutation {
    case setUpcoming
    case setTimeline
  }
  
  struct State {
    var upcomingSection = HomeSection.HomeSectionModel(
      model: .upcoming,
      items: []
    )
    var timelineSection = HomeSection.HomeSectionModel(
      model: .timeline,
      items: []
    )
  }
  
  // MARK: - Initializer
  
  init() {
    self.initialState = State()
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      return .concat([
        .just(.setUpcoming),
        .just(.setTimeline)
      ])

    case .searchButtonDidTap:
      os_log(.debug, "Search button did tap.")
      return .empty()

    case .newGiftButtonDidTap:
      os_log(.debug, "New Gift button did tap.")
      return .empty()

    case .itemSelected:
      return .empty()
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .setUpcoming:
      let upcomings = self.getUpcomingMock()
      let upcomingItems = upcomings.map {
        let reactor = UpcomingCellReactor(cellData: $0)
        return HomeSection.HomeSectionItem.upcoming(reactor)
      }
      let upcomingSectionModel = HomeSection.HomeSectionModel(
        model: .upcoming,
        items: upcomingItems
      )
      newState.upcomingSection = upcomingSectionModel
    case .setTimeline:
      let timelines = self.getTimelineMock()
      let timelineItems = timelines.map {
        let reactor = TimelineCellReactor(cellData: $0)
        return HomeSection.HomeSectionItem.timeline(reactor)
      }

      if timelineItems.isEmpty {
        let timelineSectionModel = HomeSection.HomeSectionModel(
          model: .timeline,
          items: [.empty(nil, "ㄴㅇ리ㅏㅓ")]
        )
        newState.timelineSection = timelineSectionModel
      } else {
        let timelineSectionModel = HomeSection.HomeSectionModel(
          model: .timeline,
          items: timelineItems
        )
        newState.timelineSection = timelineSectionModel
      }
    }

    return newState
  }
}

private extension HomeViewReactor {
  func getUpcomingMock() -> [CardCellData] {
    (1...2).map {
      CardCellData(
        iconImage: UIImage(named: "p\($0)"),
        title: "기념일 \($0)",
        subtitle: "2023. 03. 0\($0)"
      )
    }
  }

  func getTimelineMock() -> [TimelineCellData] {
//    return (1...3).map {
//      TimelineCellData(image: UIImage(named: "d\($0)"), isPinned: false)
//    }
    return []
  }
}
