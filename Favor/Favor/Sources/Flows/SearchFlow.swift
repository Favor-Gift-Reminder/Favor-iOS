//
//  SearchFlow.swift
//  Favor
//
//  Created by 이창준 on 2023/02/07.
//

import UIKit

import FavorKit
import RxCocoa
import RxFlow
import RxSwift

@MainActor
final class SearchFlow: Flow {

  // MARK: - Properties
  
  var root: Presentable { self.rootViewController }
  private let rootViewController: BaseNavigationController

  // MARK: - Initializer

  init(rootViewController: BaseNavigationController) {
    self.rootViewController = rootViewController
  }

  // MARK: - Navigate
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .searchIsRequired:
      return self.navigateToSearch()

    case .searchIsComplete:
      return self.navigateToHome()

    case .searchResultIsRequired(let queryString):
      return self.navigateToSearchResult(with: queryString)

    case .searchResultIsComplete:
      return self.popSearchResult()

    default:
      return .none
    }
  }
}

// MARK: - Navigates

private extension SearchFlow {
  func navigateToSearch() -> FlowContributors {
    let searchVC = SearchViewController()
    let searchReactor = SearchViewReactor(mode: .search)
    searchVC.reactor = searchReactor

    DispatchQueue.main.async {
      self.rootViewController.pushViewController(searchVC, animated: true)
      self.rootViewController.setNavigationBarHidden(true, animated: false)
    }

    return .one(flowContributor: .contribute(
      withNextPresentable: searchVC,
      withNextStepper: searchReactor
    ))
  }

  func navigateToSearchResult(with searchQuery: String) -> FlowContributors {
    let searchResultVC = SearchResultViewController()
    let searchResultReactor = SearchViewReactor(mode: .result, searchQuery: searchQuery)
    searchResultVC.reactor = searchResultReactor

    DispatchQueue.main.async {
      self.rootViewController.pushViewController(searchResultVC, animated: true)
      searchResultVC.requestSearchQuery(with: searchQuery)
    }

    return .one(flowContributor: .contribute(
      withNextPresentable: searchResultVC,
      withNextStepper: searchResultReactor
    ))
  }

  func popSearchResult() -> FlowContributors {
    self.rootViewController.popViewController(animated: true)
    return .none
  }

  func navigateToHome() -> FlowContributors {
    self.rootViewController.popViewController(animated: true)
    self.rootViewController.setNavigationBarHidden(false, animated: false)
    return .end(forwardToParentFlowWithStep: AppStep.searchIsComplete)
  }
}
