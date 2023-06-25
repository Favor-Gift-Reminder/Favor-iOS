//
//  AuthTermViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/03/02.
//

import UIKit
import OSLog

import FavorKit
import ReactorKit
import RxCocoa
import RxDataSources
import RxFlow

public final class AuthTermViewReactor: Reactor, Stepper {

  // MARK: - Properties

  public var initialState: State
  public var steps = PublishRelay<Step>()

  public enum Action {
    case viewNeedsLoaded
    case acceptAllDidTap
    case itemSelected(IndexPath)
    case nextButtonDidTap
  }

  public enum Mutation {
    case updateTerms([Terms])
    case toggleAllTerms
    case validateNextButton
  }

  public struct State {
    var userProfile: UIImage?
    var userName: String
    var terms: [Terms] = []
    var termItems: [AuthTermSectionItem] = []
    var isAllAccepted: Bool = false
    var isNextButtonEnabled: Bool = false
  }

  // MARK: - Initializer

  init(with user: User) {
    self.initialState = State(
      userProfile: user.profilePhoto,
      userName: user.name
    )
  }

  // MARK: - Functions

  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewNeedsLoaded:
      return .just(.updateTerms(self.fetchTerms()))

    case .acceptAllDidTap:
      return .concat([
        .just(.toggleAllTerms),
        .just(.validateNextButton)
      ])

    case .itemSelected(let indexPath):
      var terms = self.currentState.terms
      terms[indexPath.item].isAccepted.toggle()
      print(terms)
      return .concat([
        .just(.updateTerms(terms)),
        .just(.validateNextButton)
      ])
      
    case .nextButtonDidTap:
      os_log(.debug, "Next button did tap.")
      if self.currentState.isNextButtonEnabled {
        FTUXStorage.isSignedIn = true
        self.steps.accept(AppStep.tabBarIsRequired)
      }
      return .empty()
    }
  }

  public func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .updateTerms(let terms):
      newState.terms = terms

    case .toggleAllTerms:
      newState.isAllAccepted.toggle()
      newState.terms = state.terms.map { term in
        var newTerm = term
        newTerm.isAccepted = newState.isAllAccepted
        return newTerm
      }

    case .validateNextButton:
      if state.terms.first(where: { $0.isRequired && !$0.isAccepted }) != nil {
        newState.isNextButtonEnabled = false
      } else {
        newState.isNextButtonEnabled = true
      }
    }

    return newState
  }

  public func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state

      newState.termItems = state.terms.map { AuthTermSectionItem(terms: $0) }
      newState.isAllAccepted = state.terms.filter { !$0.isAccepted }.isEmpty

      return newState
    }
  }
}

// MARK: - Privates

private extension AuthTermViewReactor {
  func fetchTerms() -> [Terms] {
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

    return decodedTerms.sorted(by: { $0.index < $1.index })
  }
}
