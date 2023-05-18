//
//  AnniversaryListFlow.swift
//  Favor
//
//  Created by 이창준 on 2023/05/16.
//

import UIKit

import FavorKit
import RxFlow

final class AnniversaryListFlow: Flow {

  // MARK: - Properties

  var root: Presentable { self.rootViewController }
  let rootViewController: BaseNavigationController

  // MARK: - Initializer

  init(rootViewController: BaseNavigationController) {
    self.rootViewController = rootViewController
  }

  // MARK: - Navigate

  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }

    switch step {
    case .anniversaryListIsRequired:
      return self.navigateToAnniversaryList()

    case .editAnniversaryListIsRequired(let anniversaries):
      return self.navigateToEditAnniversaryList(with: anniversaries)

    case .editAnniversaryIsRequired(let anniversary):
      return self.navigateToEditAnniversary(with: anniversary)

    case .anniversaryListIsComplete:
      return self.navigateToMyPage()

    default:
      return .none
    }
  }
}

// MARK: - Navigates

private extension AnniversaryListFlow {
  func navigateToAnniversaryList() -> FlowContributors {
    let anniversaryListVC = AnniversaryListViewController()
    let anniversaryListReactor = AnniversaryListViewReactor()
    anniversaryListVC.reactor = anniversaryListReactor
    anniversaryListVC.title = "내 기념일"

    DispatchQueue.main.async {
      self.rootViewController.setupNavigationAppearance()
      self.rootViewController.pushViewController(anniversaryListVC, animated: true)
    }

    return .one(flowContributor: .contribute(
      withNextPresentable: anniversaryListVC,
      withNextStepper: anniversaryListReactor
    ))
  }

  func navigateToEditAnniversaryList(with anniversaries: [Anniversary]) -> FlowContributors {
    let editAnniversaryListVC = EditAnniversaryListViewController()
    let editAnniversaryListReactor = EditAnniversaryListViewReactor(with: anniversaries)
    editAnniversaryListVC.reactor = editAnniversaryListReactor
    editAnniversaryListVC.title = "편집하기"

    DispatchQueue.main.async {
      self.rootViewController.setupNavigationAppearance()
      self.rootViewController.pushViewController(editAnniversaryListVC, animated: true)
    }

    return .one(flowContributor: .contribute(
      withNextPresentable: editAnniversaryListVC,
      withNextStepper: editAnniversaryListReactor
    ))
  }

  func navigateToEditAnniversary(with anniversary: Anniversary) -> FlowContributors {
    let editAnniversaryVC = EditAnniversaryViewController()
    let editAnniversaryReactor = EditAnniversaryViewReactor(with: anniversary)
    editAnniversaryVC.reactor = editAnniversaryReactor
    editAnniversaryVC.title = "기념일 수정"

    DispatchQueue.main.async {
      self.rootViewController.setupNavigationAppearance()
      self.rootViewController.pushViewController(editAnniversaryVC, animated: true)
    }

    return .one(flowContributor: .contribute(
      withNextPresentable: editAnniversaryVC,
      withNextStepper: editAnniversaryReactor
    ))
  }

  func navigateToMyPage() -> FlowContributors {
    DispatchQueue.main.async {
      self.rootViewController.popViewController(animated: true)
    }
    return .end(forwardToParentFlowWithStep: AppStep.anniversaryListIsComplete)
  }
}
