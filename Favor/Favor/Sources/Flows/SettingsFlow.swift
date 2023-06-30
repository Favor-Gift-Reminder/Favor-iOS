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

    case .newPasswordIsRequired:
      return self.navigateToNewPassword()

    case .newPasswordIsComplete:
      if self.rootViewController.topViewController is SettingsNewPasswordViewController {
        self.rootViewController.popViewController(animated: true)
      }
      return .none

    case .localAuthIsRequired(let location):
      return self.navigateToLocalAuth(location: location)

    case .localAuthIsComplete:
      return self.popToSettings()

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

    case .wayBackToRootIsRequired:
      self.rootViewController.popToRootViewController(animated: false)
      return .end(forwardToParentFlowWithStep: AppStep.wayBackToRootIsRequired)

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
    let settingsAuthInfoVC = SettingsAuthInfoViewController()
    let settingsAuthInfoReactor = SettingsAuthInfoViewReactor()
    settingsAuthInfoVC.reactor = settingsAuthInfoReactor
    settingsAuthInfoVC.title = "로그인 정보"

    DispatchQueue.main.async {
      self.rootViewController.pushViewController(settingsAuthInfoVC, animated: true)
    }

    return .one(flowContributor: .contribute(
      withNextPresentable: settingsAuthInfoVC,
      withNextStepper: settingsAuthInfoReactor
    ))
  }

  func navigateToNewPassword() -> FlowContributors {
    let newPasswordVC = SettingsNewPasswordViewController()
    let newPasswordReactor = AuthNewPasswordViewReactor(.settings)
    newPasswordVC.reactor = newPasswordReactor
    newPasswordVC.title = "비밀번호 변경"

    DispatchQueue.main.async {
      self.rootViewController.pushViewController(newPasswordVC, animated: true)
    }

    return .one(flowContributor: .contribute(
      withNextPresentable: newPasswordVC,
      withNextStepper: newPasswordReactor
    ))
  }

  func navigateToLocalAuth(location: LocalAuthLocation) -> FlowContributors {
    typealias DescriptionMessage = LocalAuthViewController.DescriptionMessage
    let localAuthVC = LocalAuthViewController()
    let description: DescriptionMessage
    let animated: Bool
    switch location {
    case .settingsCheckOld:
      localAuthVC.titleString = "암호 변경"
      description = DescriptionMessage(description: "기존 암호를 입력해주세요.")
      animated = true
    case .settingsNew:
      if UserInfoStorage.isLocalAuthEnabled {
        localAuthVC.titleString = "암호 변경"
        description = DescriptionMessage(description: "변경할 암호를 입력해주세요.")
      } else {
        localAuthVC.titleString = "암호 등록"
        description = DescriptionMessage(description: "새로운 암호를 입력해주세요.")
      }
      animated = true
    case .settingsConfirmNew:
      localAuthVC.titleString = "암호 확인"
      description = DescriptionMessage(description: "새로운 암호를 입력해주세요.")
      animated = false
    default:
      description = DescriptionMessage()
      animated = true
    }
    let localAuthReactor = LocalAuthViewReactor(location, description: description)
    localAuthVC.reactor = localAuthReactor

    DispatchQueue.main.async {
      self.rootViewController.pushViewController(localAuthVC, animated: animated)
    }

    return .one(flowContributor: .contribute(
      withNextPresentable: localAuthVC,
      withNextStepper: localAuthReactor
    ))
  }

  func popToSettings() -> FlowContributors {
    DispatchQueue.main.async {
      let viewControllers = self.rootViewController.viewControllers
      if let settingsVC = viewControllers.first(where: { $0 is SettingsViewController }) {
        self.rootViewController.popToViewController(settingsVC, animated: true)
      }
    }

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
