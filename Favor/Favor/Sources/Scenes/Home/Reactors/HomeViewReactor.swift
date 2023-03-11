//
//  HomeViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2022/12/30.
//

import UIKit

import ReactorKit
import RxCocoa
import RxFlow

final class HomeViewReactor: Reactor, Stepper {
  
  // MARK: - Properties
  
  var initialState: State
  var steps = PublishRelay<Step>()
  
  enum Action {
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
    case .itemSelected:
      return .empty()
    }
  }
}

private extension HomeViewReactor {
  
  static func setupSections() -> [HomeSection] {
//    let upcomingOne = HomeSectionItem.upcomingCell(UpcomingCellReactor(text: "1"))
//    let upcomingTwo = HomeSectionItem.upcomingCell(UpcomingCellReactor(text: "2"))
    let emptyUpcoming = HomeSectionItem.emptyCell("이벤트가 없습니다.")
    let upcomingSection = HomeSection.upcoming([emptyUpcoming])
    
//    let timelineOne = HomeSectionItem.timelineCell(TimelineCellReactor(text: "1"))
//    let timelineTwo = HomeSectionItem.timelineCell(TimelineCellReactor(text: "2"))
//    let timelineThree = HomeSectionItem.timelineCell(TimelineCellReactor(text: "3"))
    let emptyTimeline = HomeSectionItem.emptyCell("선물 기록이 없습니다.")
    let timelineSection = HomeSection.timeline([emptyTimeline])
    
    return [upcomingSection, timelineSection]
  }
  
}
