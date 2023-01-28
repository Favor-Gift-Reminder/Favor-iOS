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
		
	}
	
	struct State {
		
	}
	
	// MARK: - Initializer
	
	init() {
		self.initialState = State()
	}
	
	// MARK: - Functions
	
	
}
