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
final class AuthFlow: Flow {
  
  var root: Presentable {
    return self.rootViewController
  }
  
  private lazy var rootViewController: BaseNavigationController = {
    let viewController = BaseNavigationController()
    return viewController
  }()
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .authIsRequired:
      return self.navigateToAuth()

    case .onboardingIsRequired:
      return self.navigateToOnboarding()

    case .onboardingIsComplete:
      self.rootViewController.presentedViewController?.dismiss(animated: true)
      return .none
      
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

    case .imagePickerIsRequired(let manager):
      return self.presentPHPicker(manager: manager)

    case .tabBarIsRequired:
      return .end(forwardToParentFlowWithStep: AppStep.rootIsRequired)
      
    default:
      return .none
    }
  }
}

private extension AuthFlow {
  func navigateToAuth() -> FlowContributors {
    let viewController = AuthEntryViewController()
    let reactor = AuthEntryViewReactor()
    viewController.reactor = reactor
    self.rootViewController.setViewControllers([viewController], animated: true)
    
    return .one(flowContributor: .contribute(
      withNextPresentable: viewController,
      withNextStepper: reactor
    ))
  }
  
  func navigateToOnboarding() -> FlowContributors {
    let onboardingFlow = OnboardingFlow()

    Flows.use(onboardingFlow, when: .created) { [unowned self] root in
      DispatchQueue.main.async {
        root.modalPresentationStyle = .overFullScreen
        self.rootViewController.present(root, animated: true)
      }
    }

    return .one(flowContributor: .contribute(
      withNextPresentable: onboardingFlow,
      withNextStepper: OneStepper(withSingleStep: AppStep.onboardingIsRequired)
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
    let reactor = AuthNewPasswordViewReactor()
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

  func presentPHPicker(manager: PHPickerManager) -> FlowContributors {
    manager.presentPHPicker(at: self.rootViewController)
    return .none
  }
}
