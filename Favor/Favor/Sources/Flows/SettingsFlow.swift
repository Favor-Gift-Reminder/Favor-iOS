//
//  SettingsFlow.swift
//  Favor
//
//  Created by 이창준 on 6/28/23.
//

import UIKit

import FavorKit
import RxFlow

@MainActor
public final class SettingsFlow: Flow {

  // MARK: - Properties

  public var root: Presentable { self.rootViewController }

  private let rootViewController: BaseNavigationController

  // MARK: - Initializer

  init(rootViewController: BaseNavigationController) {
    self.rootViewController = rootViewController
  }

  // MARK: - Navigate

  public func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }

    switch step {
    case .settingsIsRequired:
      return self.navigateToSettings()

    case .authInfoIsRequired:
      return self.navigateToAuthInfo()

    case .changePasswordIsRequired:
      return self.navigateToChangePassword()

    case .appLockIsRequired:
      return self.navigateToAppLock()

    case .devTeamInfoIsRequired:
      return self.navigateToDevTeamInfo()

    case .devTeamSupportIsRequired:
      return self.navigateToDevTeamSupport()

    case .serviceUsageTermIsRequired:
      return self.navigateToServiceUsageTerm()

    case .privateInfoManagementTermIsRequired:
      return self.navigateToPrivateInfoManagementTerm()

    case .openSourceUsageIsRequired:
      return self.navigateToOpenSourceUsage()

    default:
      return .none
    }
  }
}

// MARK: - Navigates

private extension SettingsFlow {
  func navigateToSettings() -> FlowContributors {
    let settingsVC = SettingsViewController()
    let settingsReactor = SettingsViewReactor()
    settingsVC.reactor = settingsReactor
    settingsVC.title = "설정"
    settingsVC.hidesBottomBarWhenPushed = true

    DispatchQueue.main.async {
      self.rootViewController.pushViewController(settingsVC, animated: true)
    }

    return .one(flowContributor: .contribute(
      withNextPresentable: settingsVC,
      withNextStepper: settingsReactor
    ))
  }

  func navigateToAuthInfo() -> FlowContributors {
    return .none
  }

  func navigateToChangePassword() -> FlowContributors {
    return .none
  }

  func navigateToAppLock() -> FlowContributors {
    return .none
  }

  func navigateToDevTeamInfo() -> FlowContributors {
    return .none
  }

  func navigateToDevTeamSupport() -> FlowContributors {
    return .none
  }

  func navigateToServiceUsageTerm() -> FlowContributors {
    return .none
  }

  func navigateToPrivateInfoManagementTerm() -> FlowContributors {
    return .none
  }

  func navigateToOpenSourceUsage() -> FlowContributors {
    return .none
  }
}
