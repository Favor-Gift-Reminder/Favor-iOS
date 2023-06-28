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
      return self.popSearch()

    case .searchResultIsRequired(let queryString):
      return self.navigateToSearchResult(with: queryString)

    case .searchResultIsComplete:
      return self.popSearchResult()

    case .searchCategoryResultIsRequired(let category):
      return self.navigateToSearchCategoryResult(with: category)

    case .searchEmotionResultIsRequired(let emotion):
      return self.navigateToSearchEmotionResult(with: emotion)

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
    searchVC.hidesBottomBarWhenPushed = true

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

  func navigateToSearchCategoryResult(with category: FavorCategory) -> FlowContributors {
    let searchCategoryVC = SearchCategoryViewController()
    let searchCategoryReactor = SearchTagViewReactor()
    searchCategoryVC.reactor = searchCategoryReactor
    searchCategoryVC.title = "선물 카테고리"

    DispatchQueue.main.async {
      self.rootViewController.pushViewController(searchCategoryVC, animated: true)
      self.rootViewController.setNavigationBarHidden(false, animated: false)
      searchCategoryVC.requestCategory(category)
    }

    return .one(flowContributor: .contribute(
      withNextPresentable: searchCategoryVC, withNextStepper: searchCategoryReactor
    ))
  }

  func navigateToSearchEmotionResult(with emotion: FavorEmotion) -> FlowContributors {
    let searchEmotionVC = SearchEmotionViewController()
    let searchEmotionReactor = SearchTagViewReactor()
    searchEmotionVC.reactor = searchEmotionReactor
    searchEmotionVC.title = "선물 감정"

    DispatchQueue.main.async {
      self.rootViewController.pushViewController(searchEmotionVC, animated: true)
      self.rootViewController.setNavigationBarHidden(false, animated: false)
      searchEmotionVC.requestEmotion(emotion)
    }

    return .one(flowContributor: .contribute(
      withNextPresentable: searchEmotionVC, withNextStepper: searchEmotionReactor
    ))
  }

  func popSearchResult() -> FlowContributors {
    self.rootViewController.popViewController(animated: true)
    return .none
  }

  func popSearch() -> FlowContributors {
    self.rootViewController.popViewController(animated: true)
    self.rootViewController.setNavigationBarHidden(false, animated: false)
    return .end(forwardToParentFlowWithStep: AppStep.searchIsComplete)
  }
}
