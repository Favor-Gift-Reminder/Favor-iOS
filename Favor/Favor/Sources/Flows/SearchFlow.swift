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

    case .searchIsComplete:
      self.rootViewController.popViewController(animated: true)
      self.rootViewController.setNavigationBarHidden(false, animated: false)
      return .end(forwardToParentFlowWithStep: AppStep.searchIsComplete)

    case .searchResultIsRequired(let queryString):
      let searchResultVC = SearchResultViewController()
      let searchResultReactor = SearchViewReactor(mode: .result, searchQuery: queryString)
      searchResultVC.reactor = searchResultReactor

      DispatchQueue.main.async {
        self.rootViewController.pushViewController(searchResultVC, animated: true)
        searchResultVC.requestSearchQuery(with: queryString)
      }

      return .one(flowContributor: .contribute(
        withNextPresentable: searchResultVC,
        withNextStepper: searchResultReactor
      ))
      
    case .searchResultIsComplete:
      self.rootViewController.popViewController(animated: true)
      return .none
      
    case .searchCategoryResultIsRequired(let category):
      let searchCategoryVC = SearchCategoryViewController()
      let searchCategoryReactor = SearchTagViewReactor(.category(category))
      searchCategoryVC.reactor = searchCategoryReactor
      searchCategoryVC.title = "선물 카테고리"
      
      DispatchQueue.main.async {
        self.rootViewController.pushViewController(searchCategoryVC, animated: true)
        self.rootViewController.setNavigationBarHidden(false, animated: false)
      }
      
      return .one(flowContributor: .contribute(
        withNextPresentable: searchCategoryVC, withNextStepper: searchCategoryReactor
      ))
      
    case .searchEmotionResultIsRequired(let emotion):
      let searchEmotionVC = SearchEmotionViewController()
      let searchEmotionReactor = SearchTagViewReactor(.emotion(emotion))
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
      
    case .giftDetailIsRequired(let gift):
      let flow = GiftDetailFlow(rootViewController: self.rootViewController)
      return .one(flowContributor: .contribute(
        withNextPresentable: flow,
        withNextStepper: OneStepper(withSingleStep: AppStep.giftDetailIsRequired(gift))
      ))

    default:
      return .none
    }
  }
}
