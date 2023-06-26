//
//  AuthValidateEmailViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/03/04.
//

import ReactorKit
import RxCocoa
import RxFlow

public final class AuthValidateEmailViewReactor: Reactor, Stepper {

  // MARK: - Properties

  public var initialState: State
  public var steps = PublishRelay<Step>()

  public enum Action {
    case emailCodeTextFieldDidUpdate(String)
    case nextFlowRequested
  }

  public enum Mutation {
    case updateEmailCode(String)
  }

  public struct State {
    let email: String
    var emailCode: String = ""
  }

  // MARK: - Initializer

  init(with email: String) {
    self.initialState = State(
      email: email
    )
  }


  // MARK: - Functions

  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .emailCodeTextFieldDidUpdate(let code):
      return .just(.updateEmailCode(code))

    case .nextFlowRequested:
      self.steps.accept(AppStep.newPasswordIsRequired)
      return .empty()
    }
  }

  public func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .updateEmailCode(let emailCode):
      newState.emailCode = emailCode
    }

    return newState
  }
}
