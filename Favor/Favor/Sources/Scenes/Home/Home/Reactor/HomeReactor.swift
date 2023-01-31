//
//  HomeReactor.swift
//  Favor
//
//  Created by 이창준 on 2022/12/30.
//

import ReactorKit

import RxCocoa
import RxFlow

final class HomeReactor: Reactor, Stepper {
	
	// MARK: - Properties
	
	var initialState: State
  var steps = PublishRelay<Step>()
	
	enum Action {
		case viewDidLoad
	}
  
  enum Mutation {
    case loadMockData([UpcomingSection])
  }
	
	struct State {
    var sections: [UpcomingSection] = []
	}
	
	// MARK: - Initializer
	
	init() {
		self.initialState = State()
	}
	
	// MARK: - Functions
	
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      let mockSections = [
        UpcomingSection(header: "one", items: ["1", "2", "3"])
      ]
      return .just(.loadMockData(mockSections))
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .loadMockData(let sections):
      print(sections)
      newState.sections = sections
    }
    
    return newState
  }
}
