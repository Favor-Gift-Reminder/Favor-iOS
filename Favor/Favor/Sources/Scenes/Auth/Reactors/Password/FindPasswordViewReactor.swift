//
//  FindPasswordViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/03/04.
//

import OSLog

import ReactorKit
import RxCocoa
import RxFlow

final class FindPasswordViewReactor: Reactor, Stepper {

  // MARK: - Properties

  var initialState: State
  var steps = PublishRelay<Step>()

  // Global States
  let emailValidate = BehaviorRelay<ValidationResult>(value: .empty)

  enum Action {
    case viewWillAppear
    case emailTextFieldDidUpdate(String)
    case nextFlowRequested
  }

  enum Mutation {
    case updateEmail(String)
    case updateEmailValidation(ValidationResult)
  }

  struct State {
    var email: String = ""
    var isNextButtonEnabled: Bool = false
  }

  // MARK: - Initializer

  init() {
    self.initialState = State()
  }


  // MARK: - Functions

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewWillAppear:
      os_log(.debug, "View will appear.")
      return .empty()

    case .emailTextFieldDidUpdate(let email):
      os_log(.debug, "Email TextField did update: \(email)")
      let emailValidate = AuthValidationManager(type: .email).validate(email)
      return .concat([
        .just(.updateEmail(email)),
        .just(.updateEmailValidation(emailValidate))
      ])

    case .nextFlowRequested:
      os_log(.debug, "Next button or return key from keyboard did tap.")
      if self.currentState.isNextButtonEnabled {
        self.steps.accept(AppStep.validateEmailCodeIsRequired(self.currentState.email))
      }
      return .empty()
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .updateEmail(let email):
      newState.email = email

    case .updateEmailValidation(let emailValidate):
      newState.isNextButtonEnabled = emailValidate == .valid ? true : false
    }

    return newState
  }
}
