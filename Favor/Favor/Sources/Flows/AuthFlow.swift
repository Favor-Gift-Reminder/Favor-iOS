//
//  AuthFlow.swift
//  Favor
//
//  Created by 김응철 on 2023/02/01.
//

import UIKit

import FavorKit
import RxFlow

@MainActor
public final class AuthFlow: Flow {

  // MARK: - Properties

  public var root: Presentable {
    return self.rootViewController
  }
  
  private let rootViewController: BaseNavigationController

  // MARK: - Initializer

  init() {
    self.rootViewController = BaseNavigationController()
  }

  // MARK: - Navigate

  public func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .authIsRequired:
      return self.navigateToAuth()
      
    case .signInIsRequired:
      return self.navigateToSignIn()

    case .findPasswordIsRequired:
      return self.navigateToFindPassword()

    case .validateEmailCodeIsRequired(let email):
      return self.navigateToValidateEmailCode(with: email)

    case .newPasswordIsRequired:
      return self.navigateToNewPassword()
      
    case .signUpIsRequired:
      return self.navigateToSignUp()
      
    case .setProfileIsRequired(let user):
      return self.navigateToSetProfile(with: user)

    case .termIsRequired(let user):
      return self.navigateToTerm(with: user)

    case .authIsComplete:
      return .end(forwardToParentFlowWithStep: AppStep.dashboardIsRequired)
      
    default:
      return .none
    }
  }
}

// MARK: - Navigates

private extension AuthFlow {
  func navigateToAuth() -> FlowContributors {
    let authEntryVC = AuthEntryViewController()
    let authEntryReactor = AuthEntryViewReactor()
    authEntryVC.reactor = authEntryReactor

    DispatchQueue.main.async {
      self.rootViewController.pushViewController(authEntryVC, animated: false)
    }

    return .one(flowContributor: .contribute(
      withNextPresentable: authEntryVC,
      withNextStepper: authEntryReactor
    ))
  }
  
  func navigateToSignIn() -> FlowContributors {
    let viewController = AuthSignInViewController()
    let reactor = AuthSignInViewReactor()
    viewController.title = "로그인"
    viewController.reactor = reactor
    self.rootViewController.pushViewController(viewController, animated: true)
    
    return .one(flowContributor: .contribute(
      withNextPresentable: viewController,
      withNextStepper: reactor)
    )
  }

  func navigateToFindPassword() -> FlowContributors {
    let viewController = AuthFindPasswordViewController()
    let reactor = AuthFindPasswordViewReactor()
    viewController.title = "비밀번호 찾기"
    viewController.reactor = reactor
    self.rootViewController.pushViewController(viewController, animated: true)

    return .one(flowContributor: .contribute(
      withNextPresentable: viewController,
      withNextStepper: reactor)
    )
  }

  func navigateToValidateEmailCode(with email: String) -> FlowContributors {
    let viewController = AuthValidateEmailViewController()
    let reactor = AuthValidateEmailViewReactor(with: email)
    viewController.title = "비밀번호 찾기"
    viewController.reactor = reactor
    self.rootViewController.pushViewController(viewController, animated: true)

    return .one(flowContributor: .contribute(
      withNextPresentable: viewController,
      withNextStepper: reactor)
    )
  }

  func navigateToNewPassword() -> FlowContributors {
    let viewController = AuthNewPasswordViewController()
    let reactor = AuthNewPasswordViewReactor(.auth)
    viewController.title = "비밀번호 변경"
    viewController.reactor = reactor
    self.rootViewController.pushViewController(viewController, animated: true)

    return .one(flowContributor: .contribute(
      withNextPresentable: viewController,
      withNextStepper: reactor)
    )
  }
  
  func navigateToSignUp() -> FlowContributors {
    let viewController = AuthSignUpViewController()
    let reactor = AuthSignUpViewReactor()
    viewController.title = "회원가입"
    viewController.reactor = reactor
    self.rootViewController.pushViewController(viewController, animated: true)
    
    return .one(flowContributor: .contribute(
      withNextPresentable: viewController,
      withNextStepper: reactor)
    )
  }
  
  func navigateToSetProfile(with user: User) -> FlowContributors {
    let viewController = AuthSetProfileViewController()
    let reactor = AuthSetProfileViewReactor(user)
    viewController.title = "프로필 작성"
    viewController.reactor = reactor
    self.rootViewController.pushViewController(viewController, animated: true)
    
    return .one(flowContributor: .contribute(
      withNextPresentable: viewController,
      withNextStepper: reactor)
    )
  }
  
  func navigateToTerm(with user: User) -> FlowContributors {
    let viewController = AuthTermViewController()
    let reactor = AuthTermViewReactor(with: user)
    viewController.reactor = reactor
    self.rootViewController.pushViewController(viewController, animated: true)
    
    return .one(flowContributor: .contribute(
      withNextPresentable: viewController,
      withNextStepper: reactor)
    )
  }
}
