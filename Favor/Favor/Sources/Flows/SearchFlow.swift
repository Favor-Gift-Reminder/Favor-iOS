//
//  SearchFlow.swift
//  Favor
//
//  Created by 이창준 on 2023/02/07.
//

import UIKit

import RxCocoa
import RxFlow
import RxSwift

final class SearchFlow: Flow {
  
  var root: Presentable { self.rootViewController }
  
  private lazy var rootViewController: UINavigationController = {
    let navigationController = UINavigationController()
    navigationController.isNavigationBarHidden = true
    return navigationController
  }()
  
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
  
  private func navigateToSearch() -> FlowContributors {
    let searchVC = SearchViewController()
    let searchReactor = SearchViewReactor()
    searchVC.reactor = searchReactor
    self.rootViewController.setViewControllers([searchVC], animated: true)
    return .one(flowContributor: .contribute(
      withNextPresentable: searchVC,
      withNextStepper: searchReactor
    ))
  }
  
  private func navigateToSearchResult() -> FlowContributors {
    let searchResultVC = SearchResultViewController()
    let searchResultReactor = SearchResultViewReactor()
    searchResultVC.reactor = searchResultReactor
    self.rootViewController.pushViewController(searchResultVC, animated: true)
    return .one(flowContributor: .contribute(
      withNextPresentable: searchResultVC,
      withNextStepper: searchResultReactor
    ))
  }
}
