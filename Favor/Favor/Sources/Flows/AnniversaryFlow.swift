//
//  AnniversaryFlow.swift
//  Favor
//
//  Created by 이창준 on 2023/05/16.
//

import UIKit

import FavorKit
import RxFlow

@MainActor
final class AnniversaryFlow: Flow {

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
    case .anniversaryListIsRequired(let anniversaryListType):
      return self.navigateToAnniversaryList(anniversaryListType)

    case .editAnniversaryListIsRequired(let anniversaries):
      return self.navigateToEditAnniversaryList(with: anniversaries)

    case .newAnniversaryIsRequired:
      return self.navigateToAnniversaryManagement(.new)

    case .anniversaryManagementIsRequired(let anniversary):
      return self.navigateToAnniversaryManagement(.edit, with: anniversary)

    case .anniversaryManagementIsComplete(let message):
      return self.popFromAnniversaryModifying(with: message)

    case .anniversaryListIsComplete:
      return self.popFromAnniversaryList()
      
    default:
      return .none
    }
  }
}

// MARK: - Navigates

private extension AnniversaryFlow {
  func navigateToAnniversaryList(_ type: AnniversaryListType) -> FlowContributors {
    let anniversaryListVC = AnniversaryListViewController(type)
    let anniversaryListReactor = AnniversaryListViewReactor(type)
    anniversaryListVC.reactor = anniversaryListReactor

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
    let anniversaryListModifyingVC = AnniversaryListModifyingViewController()
    let anniversaryListModifyingReactor = AnniversaryListModifyingViewReactor(with: anniversaries)
    anniversaryListModifyingVC.reactor = anniversaryListModifyingReactor
    anniversaryListModifyingVC.title = "편집하기"

    DispatchQueue.main.async {
      self.rootViewController.setupNavigationAppearance()
      self.rootViewController.pushViewController(anniversaryListModifyingVC, animated: true)
    }

    return .one(flowContributor: .contribute(
      withNextPresentable: anniversaryListModifyingVC,
      withNextStepper: anniversaryListModifyingReactor
    ))
  }

  func navigateToAnniversaryManagement(
    _ viewType: AnniversaryManagementViewController.ViewType,
    with anniversary: Anniversary? = nil
  ) -> FlowContributors {
    let anniversaryManagementVC = AnniversaryManagementViewController()
    var anniversaryManagementReactor: AnniversaryManagementViewReactor
    switch viewType {
    case .edit:
      guard let anniversary else { return .none }
      anniversaryManagementReactor = AnniversaryManagementViewReactor(with: anniversary)
    case .new:
      anniversaryManagementReactor = AnniversaryManagementViewReactor()
    }
    anniversaryManagementVC.reactor = anniversaryManagementReactor

    DispatchQueue.main.async {
      self.rootViewController.setupNavigationAppearance()
      self.rootViewController.pushViewController(anniversaryManagementVC, animated: true)
    }

    return .one(flowContributor: .contribute(
      withNextPresentable: anniversaryManagementVC,
      withNextStepper: anniversaryManagementReactor
    ))
  }

  func popFromAnniversaryModifying(with message: ToastMessage) -> FlowContributors {
    DispatchQueue.main.async {
      if self.rootViewController.topViewController is AnniversaryManagementViewController {
        self.rootViewController.popViewController(animated: true)
        guard
          let anniversaryListModifyingVC = self.rootViewController.topViewController
            as? AnniversaryListModifyingViewController
        else { return }
        anniversaryListModifyingVC.viewNeedsLoaded(with: message)
      }
    }

    return .none
  }

  func popFromAnniversaryList() -> FlowContributors {
    DispatchQueue.main.async {
      if self.rootViewController.topViewController is AnniversaryListViewController {
        self.rootViewController.popViewController(animated: true)
      }
    }
    return .end(forwardToParentFlowWithStep: AppStep.anniversaryListIsComplete)
  }
}
