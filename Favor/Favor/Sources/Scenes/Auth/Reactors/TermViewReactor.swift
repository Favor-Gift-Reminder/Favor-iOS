//
//  TermViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/03/02.
//

import Foundation
import OSLog

import ReactorKit
import Reusable
import RxCocoa
import RxDataSources
import RxFlow

final class TermViewReactor: Reactor, Stepper {

  // MARK: - Properties

  var initialState: State
  var steps = PublishRelay<Step>()

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
    var termSections: [TermSection] = []
    var isAllAccepted: Bool = false
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
    typealias JSON = [String: Any]

    guard let filePath = Bundle.main.path(forResource: "Term-Info", ofType: "plist") else {
      fatalError("Couldn't find the 'Term-Info.plist' file.")
    }

    var terms: JSON = [:]
    do {
      var plistRAW: Data
      if #available(iOS 16.0, *) {
        plistRAW = try Data(contentsOf: URL(filePath: filePath))
      } else {
        plistRAW = try NSData(contentsOfFile: filePath) as Data
      }
      terms = try PropertyListSerialization.propertyList(from: plistRAW, format: nil) as! JSON
    } catch {
      os_log(.error, "\(error)")
    }

    var decodedTerms: [Terms] = []
    terms.forEach { term in
      guard
        let value = term.value as? JSON,
        let title = value["Title"] as? String,
        let isRequired = value["Required"] as? Bool,
        let url = value["URL"] as? String,
        let index = value["Index"] as? Int
      else { return }

      let term = Terms(title: title, isRequired: isRequired, url: url, index: index)
      decodedTerms.append(term)
    }

    let termSection = TermSection(items: decodedTerms.sorted(by: { $0.index < $1.index }))
    return [termSection]
  }
}
