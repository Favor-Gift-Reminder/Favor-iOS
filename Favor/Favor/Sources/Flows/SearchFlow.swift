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
    return navigationController
  }()
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .searchIsRequired:
      return self.navigateToSearch()
    default:
      return .none
    }
  }
  
  private func navigateToSearch() -> FlowContributors {
    let searchVC = SearchViewController()
    let searchReactor = SearchReactor()
    searchVC.reactor = searchReactor
    self.rootViewController.setViewControllers([searchVC], animated: true)
    return .one(flowContributor: .contribute(
      withNextPresentable: searchVC,
      withNextStepper: searchReactor
    ))
  }
}
