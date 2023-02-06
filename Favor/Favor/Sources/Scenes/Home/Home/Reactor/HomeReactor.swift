//
//  HomeReactor.swift
//  Favor
//
//  Created by 이창준 on 2022/12/30.
//

import UIKit

import ReactorKit
import RxCocoa
import RxFlow

final class HomeReactor: Reactor, Stepper {
  
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
      sections: HomeReactor.setupSections()
    )
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .itemSelected(let indexPath):
      print(indexPath)
      return .empty()
    }
  }
}

private extension HomeReactor {
  
  // TODO: 데이터 바인딩 되면 수정 (데이터가 비어있으면 emptyCell로 변환하여 반환)
  static func setupSections() -> [HomeSection] {
    let upcomingOne = HomeSectionItem.upcomingCell(UpcomingCellReactor(text: "1"))
    let upcomingTwo = HomeSectionItem.upcomingCell(UpcomingCellReactor(text: "2"))
//    let emptyUpcoming = HomeSectionItem.emptyCell
    let upcomingSection = HomeSection.upcoming([upcomingOne, upcomingTwo])
    
    let timelineOne = HomeSectionItem.timelineCell(TimelineCellReactor(text: "1"))
    let timelineTwo = HomeSectionItem.timelineCell(TimelineCellReactor(text: "2"))
    let timelineThree = HomeSectionItem.timelineCell(TimelineCellReactor(text: "3"))
//    let emptyTimeline = HomeSectionItem.emptyCell
    let timelineSection = HomeSection.timeline([timelineOne, timelineTwo, timelineThree])
    
    return [upcomingSection, timelineSection]
  }
  
}
