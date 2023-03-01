//
//  SignInViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/01/12.
//

import OSLog
import UIKit

import ReactorKit
import RxCocoa
import RxFlow

final class SignInViewReactor: Reactor, Stepper {
  
  // MARK: - Properties
  
  var initialState: State
  var steps = PublishRelay<Step>()
  
  enum Action {
    case viewDidLoad
    case emailDidEndOnExit
    case passwordDidEndOnExit
    case signInButtonDidTap
    case findPasswordButtonDidTap
  }
  
  enum Mutation {

  }
  
  struct State {

  }
  
  // MARK: - Initializer
  
  init() {
    self.initialState = State()
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      os_log(.debug, "View did load.")
      return .empty()
    case .emailDidEndOnExit:
      os_log(.debug, "Email TextField did end on exit.")
      return .empty()
    case .passwordDidEndOnExit:
      os_log(.debug, "Password TextField did end on exit.")
      return .empty()
    case .signInButtonDidTap:
      os_log(.debug, "Sign in button did tap.")
      return .empty()
    case .findPasswordButtonDidTap:
      os_log(.debug, "Find password button did tap.")
      return .empty()
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
      
    }

    return newState
  }
}
