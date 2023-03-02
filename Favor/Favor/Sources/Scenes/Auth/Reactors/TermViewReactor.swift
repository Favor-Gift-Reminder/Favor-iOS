//
//  TermViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/03/02.
//

import ReactorKit
import RxCocoa
import RxFlow

final class TermViewReactor: Reactor, Stepper {

  // MARK: - Properties

  var initialState: State
  var steps = PublishRelay<Step>()

  enum Action {
    case viewDidLoad
  }

  enum Mutation {
    case updateTermSection
  }

  struct State {
    var userName: String
    var termSections: [TermSection] = []
  }

  // MARK: - Initializer

  init(with userName: String) {
    self.initialState = State(
      userName: userName
    )
  }


  // MARK: - Functions

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      return .just(.updateTermSection)
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .updateTermSection:
      newState.termSections = self.setupTermSection()
    }

    return newState
  }
}

// MARK: - Privates

private extension TermViewReactor {
  func setupTermSection() -> [TermSection] {
    let terms = [
      Terms(title: "페이버 운영약관 동의 (필수)", isRequired: true),
      Terms(title: "개인정보 수집 및 이용 동의 (필수)", isRequired: true),
      Terms(title: "이벤트 정보 수신 (선택)", isRequired: false)
    ]
    let termSection = TermSection(items: terms)
    return [termSection]
  }
}
