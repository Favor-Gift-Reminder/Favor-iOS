//
//  SelectSignInViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/01/11.
//

import OSLog

import ReactorKit
import RxCocoa
import RxFlow

final class SelectSignInViewReactor: Reactor, Stepper {
  
  // MARK: - Properties
  
  var initialState: State
  var steps = PublishRelay<Step>()
  
  enum Action {
    case loadView
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
    case .loadView:
      if FTUXStorage.isFirstLaunch {
        self.steps.accept(AppStep.onboardingIsRequired)
      }
      return .empty()

    case .emailLoginButtonTap:
      self.steps.accept(AppStep.signInIsRequired)
      return .empty()
      
    case .signUpButtonTap:
      self.steps.accept(AppStep.signUpIsRequired)
      return .empty()
    }
  }
}
