//
//  HomeReactor.swift
//  Favor
//
//  Created by 이창준 on 2022/12/30.
//

import ReactorKit

final class HomeReactor: Reactor {
	
	// MARK: - Properties
	
	weak var coordinator: HomeCoordinator?
	var initialState: State
	
	enum Action {
		
	}
	
	struct State {
		
	}
	
	// MARK: - Initializer
	
	init(coordinator: HomeCoordinator) {
		self.coordinator = coordinator
		self.initialState = State()
	}
	
	// MARK: - Functions
	
	
}
