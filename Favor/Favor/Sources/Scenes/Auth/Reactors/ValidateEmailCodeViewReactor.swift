//
//  ValidateEmailCodeViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/03/04.
//

import ReactorKit
import RxCocoa
import RxFlow

final class ValidateEmailCodeViewReactor: Reactor, Stepper {

  // MARK: - Properties

  var initialState: State
  var steps = PublishRelay<Step>()

  enum Action {
    case emailCodeTextFieldDidUpdate(String)
    case nextFlowRequested
  }

  enum Mutation {
    case updateEmailCode(String)
  }

  struct State {
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

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .emailCodeTextFieldDidUpdate(let code):
      return .just(.updateEmailCode(code))

    case .nextFlowRequested:
      self.steps.accept(AppStep.newPasswordIsRequired)
      return .empty()
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .updateEmailCode(let emailCode):
      newState.emailCode = emailCode
    }

    return newState
  }
}
