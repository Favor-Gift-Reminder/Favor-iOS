//
//  AuthFlow.swift
//  Favor
//
//  Created by 김응철 on 2023/02/01.
//

import UIKit

import RxFlow

final class AuthFlow: Flow {
  
  var root: Presentable {
    return self.rootViewController
  }
  
  private lazy var rootViewController: UINavigationController = {
    let viewController = UINavigationController()
    return viewController
  }()
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .authIsRequired:
      return self.navigationToAuth()
      
    case .authIsComplete:
      return .end(forwardToParentFlowWithStep: AppStep.authIsComplete)
      
    case .signInIsRequired:
      return self.navigationToSignIn()

    case .findPasswordIsRequired:
      return self.navigateToFindPassword()

    case .validateEmailCodeIsRequired(let email):
      return self.navigateToValidateEmailCode(with: email)

    case .newPasswordIsRequired:
      return self.navigateToNewPassword()
      
    case .signUpIsRequired:
      return self.navigationToSignUp()
      
    case .setProfileIsRequired:
      return self.navigationToSetProfile()
      
    case .termIsRequired(let userName):
      return self.navigationToTerm(with: userName)
      
    case .onboardingIsRequired:
      return .none
      
    case .onboardingIsComplete:
      return .none

    case .imagePickerIsRequired(let manager):
      return self.presentPHPicker(manager: manager)
      
    default:
      return .none
    }
  }
}

private extension AuthFlow {
  func navigationToAuth() -> FlowContributors {
    let viewController = SelectSignInViewController()
    let reactor = SelectSignInViewReactor()
    viewController.reactor = reactor
    self.rootViewController.setViewControllers([viewController], animated: true)
    
    return .one(flowContributor: .contribute(
      withNextPresentable: viewController,
      withNextStepper: reactor
    ))
  }
  
  func navigationToOnboarding() -> FlowContributors {
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
  
  func navigationToSignIn() -> FlowContributors {
    let viewController = SignInViewController()
    let reactor = SignInViewReactor()
    viewController.title = "로그인"
    viewController.reactor = reactor
    self.rootViewController.pushViewController(viewController, animated: true)
    
    return .one(flowContributor: .contribute(
      withNextPresentable: viewController,
      withNextStepper: reactor)
    )
  }

  func navigateToFindPassword() -> FlowContributors {
    let viewController = FindPasswordViewController()
    let reactor = FindPasswordViewReactor()
    viewController.title = "비밀번호 찾기"
    viewController.reactor = reactor
    self.rootViewController.pushViewController(viewController, animated: true)

    return .one(flowContributor: .contribute(
      withNextPresentable: viewController,
      withNextStepper: reactor)
    )
  }

  func navigateToValidateEmailCode(with email: String) -> FlowContributors {
    let viewController = ValidateEmailCodeViewController()
    let reactor = ValidateEmailCodeViewReactor(with: email)
    viewController.title = "비밀번호 찾기"
    viewController.reactor = reactor
    self.rootViewController.pushViewController(viewController, animated: true)

    return .one(flowContributor: .contribute(
      withNextPresentable: viewController,
      withNextStepper: reactor)
    )
  }

  func navigateToNewPassword() -> FlowContributors {
    let viewController = NewPasswordViewController()
    let reactor = NewPasswordViewReactor()
    viewController.title = "비밀번호 변경"
    viewController.reactor = reactor
    self.rootViewController.pushViewController(viewController, animated: true)

    return .one(flowContributor: .contribute(
      withNextPresentable: viewController,
      withNextStepper: reactor)
    )
  }
  
  func navigationToSignUp() -> FlowContributors {
    let viewController = SignUpViewController()
    let reactor = SignUpViewReactor()
    viewController.title = "회원가입"
    viewController.reactor = reactor
    self.rootViewController.pushViewController(viewController, animated: true)
    
    return .one(flowContributor: .contribute(
      withNextPresentable: viewController,
      withNextStepper: reactor)
    )
  }
  
  func navigationToSetProfile() -> FlowContributors {
    let viewController = SetProfileViewController()
    let reactor = SetProfileViewReactor(pickerManager: PHPickerManager())
    viewController.title = "프로필 작성"
    viewController.reactor = reactor
    self.rootViewController.pushViewController(viewController, animated: true)
    
    return .one(flowContributor: .contribute(
      withNextPresentable: viewController,
      withNextStepper: reactor)
    )
  }
  
  func navigationToTerm(with userName: String) -> FlowContributors {
    let viewController = TermViewController()
    let reactor = TermViewReactor(with: userName)
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
