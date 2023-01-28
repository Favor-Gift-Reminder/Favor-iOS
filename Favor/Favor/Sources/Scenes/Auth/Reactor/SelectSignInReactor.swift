//
//  SelectSignInReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/01/11.
//

import OSLog

import ReactorKit
import RxFlow
import RxRelay

final class SelectSignInReactor: Reactor, Stepper {
  var steps = PublishRelay<Step>()
  
  // MARK: - Properties
  
  var initialState: State
  
  enum Action {
    case emailLoginButtonTap
    case signUpButtonTap
  }
  
  enum Mutation {
    
  }
  
  struct State {
    
  }
  
  // MARK: - Initializer
  
  init() {
    self.initialState = State()
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .emailLoginButtonTap:
//      self.coordinator.showSignInFlow()
      return Observable<Mutation>.empty()
    case .signUpButtonTap:
//      self.coordinator.showSignUpFlow()
      return Observable<Mutation>.empty()
    }
  }
  
}
