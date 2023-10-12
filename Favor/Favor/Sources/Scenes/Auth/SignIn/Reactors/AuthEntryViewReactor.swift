//
//  AuthEntryViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/01/11.
//

import OSLog

import FavorKit
import ReactorKit
import RxCocoa
import RxFlow

public final class AuthEntryViewReactor: Reactor, Stepper {

  // MARK: - Properties
  
  public var initialState: State
  public var steps = PublishRelay<Step>()
  
  public enum Action {
    case viewNeedsLoaded
    case signInButtonDidTap
    case signUpButtonDidTap
  }
  
  public enum Mutation { }

  public struct State { }

  // MARK: - Initializer
  
  init() {
    self.initialState = State()
  }
  
  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewNeedsLoaded:
//      if FTUXStorage.isFirstLaunch {
//        self.steps.accept(AppStep.onboardingIsRequired)
//      }
      return .empty()

    case .signInButtonDidTap:
      self.steps.accept(AppStep.signInIsRequired)
      return .empty()
      
    case .signUpButtonDidTap:
      self.steps.accept(AppStep.signUpIsRequired)
      return .empty()
    }
  }
}
