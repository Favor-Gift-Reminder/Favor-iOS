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
    case searchButtonDidTap
    case newGiftButtonDidTap
    case itemSelected(IndexPath)
  }
  
  enum Mutation {
    
  }
  
  struct State {
    var sections: [HomeSection]
  }
  
  // MARK: - Initializer
  
  init() {
    self.initialState = State(
      sections: HomeViewReactor.setupSections()
    )
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
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
}

private extension HomeViewReactor {
  
  static func setupSections() -> [HomeSection] {
    let upcomingOne = HomeSectionItem.upcomingCell(UpcomingCellReactor(cellData: CardCellData(
      iconImage: .favorIcon(.friend), title: "은기 생일", subtitle: "23. 02. 29")))
    let upcomingTwo = HomeSectionItem.upcomingCell(UpcomingCellReactor(cellData: CardCellData(
      iconImage: .favorIcon(.graduate), title: "졸업", subtitle: "23. 08. 31")))
//    let emptyUpcoming = HomeSectionItem.emptyCell("이벤트가 없습니다.")
    let upcomingSection = HomeSection.upcoming([upcomingOne, upcomingTwo])
    
    let timelineOne = HomeSectionItem.timelineCell(TimelineCellReactor(cellData: TimelineCellData()))
    let timelineTwo = HomeSectionItem.timelineCell(TimelineCellReactor(cellData: TimelineCellData()))
    let timelineThree = HomeSectionItem.timelineCell(TimelineCellReactor(cellData: TimelineCellData()))
//    let emptyTimeline = HomeSectionItem.emptyCell("선물 기록이 없습니다.")
    let timelineSection = HomeSection.timeline([timelineOne, timelineTwo, timelineThree])
    
    return [upcomingSection, timelineSection]
  }
  
}
