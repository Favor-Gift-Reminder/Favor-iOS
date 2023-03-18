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

final class SearchFlow: Flow {

  // MARK: - Properties
  
  var root: Presentable { self.rootViewController }
  private var rootViewController: BaseNavigationController

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

    case .searchResultIsRequired:
      return self.navigateToSearchResult()

    default:
      return .none
    }
  }
}

// MARK: - Navigates

private extension SearchFlow {
  func navigateToSearch() -> FlowContributors {
    let searchVC = SearchViewController()
    let searchReactor = SearchViewReactor()
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

  func navigateToSearchResult() -> FlowContributors {
    let searchResultVC = SearchResultViewController()
    let searchResultReactor = SearchResultViewReactor()
    searchResultVC.reactor = searchResultReactor
    self.rootViewController.navigationController?.pushViewController(searchResultVC, animated: true)
    return .one(flowContributor: .contribute(
      withNextPresentable: searchResultVC,
      withNextStepper: searchResultReactor
    ))
  }
}
