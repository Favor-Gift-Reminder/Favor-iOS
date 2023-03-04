//
//  TermViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/03/02.
//

import Foundation

import ReactorKit
import Reusable
import RxCocoa
import RxDataSources
import RxFlow

final class TermViewReactor: Reactor, Stepper {

  // MARK: - Properties

  var initialState: State
  var steps = PublishRelay<Step>()

  let dataSource = RxTableViewSectionedReloadDataSource<TermSection>(
    configureCell: { _, tableView, indexPath, item in
      let cell = tableView.dequeueReusableCell(for: indexPath) as AcceptTermCell
      cell.bind(terms: item)
      return cell
    }
  )

  enum Action {
    case viewDidLoad
    case acceptAllDidTap
    case itemSelected(IndexPath)
  }

  enum Mutation {
    case setupTermSection
    case checkIfAllAccepted
    case toggleAllTerms
    case updateTermSection(IndexPath)
    case validateNextButton
  }

  struct State {
    var userName: String
    var isAllAccepted: Bool = false
    var termSections: [TermSection] = []
    var isNextButtonEnabled: Bool = false
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
      return .just(.setupTermSection)

    case .acceptAllDidTap:
      return .concat([
        .just(.toggleAllTerms),
        .just(.validateNextButton)
      ])

    case .itemSelected(let indexPath):
      return .concat([
        .just(.updateTermSection(indexPath)),
        .just(.checkIfAllAccepted),
        .just(.validateNextButton)
      ])
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .setupTermSection:
      newState.termSections = self.setupTermSection()

    case .checkIfAllAccepted:
      newState.isAllAccepted = true
      for section in newState.termSections {
        for term in section.items where !term.isAccepted {
          newState.isAllAccepted = false
        }
      }

    case .toggleAllTerms:
      newState.isAllAccepted.toggle()
      for section in 0 ..< newState.termSections.count {
        for row in 0 ..< newState.termSections[section].items.count {
          newState.termSections[section].items[row].isAccepted = newState.isAllAccepted
        }
      }

    case .updateTermSection(let indexPath):
      newState.termSections[indexPath.section].items[indexPath.row].isAccepted.toggle()

    case .validateNextButton:
      newState.isNextButtonEnabled = true
      for section in newState.termSections {
        for term in section.items where term.isRequired && !term.isAccepted {
          newState.isNextButtonEnabled = false
        }
      }
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
