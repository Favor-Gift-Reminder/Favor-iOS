//
//  AppFlow.swift
//  Favor
//
//  Created by 이창준 on 2023/01/27.
//

import AuthenticationServices
import OSLog
import UIKit

import FavorKit
import RxCocoa
import RxFlow
import RxSwift

@MainActor
public final class AppFlow: Flow {

  // MARK: - Properties

  public var root: Presentable { self.rootViewController }
  private let keychain = KeychainManager()

  /// Used only for testFlow.
  private let rootViewController: UINavigationController

  // Comment this Initializer.
  public init(_ rootViewController: UINavigationController) {
    self.rootViewController = rootViewController
  }

  // MARK: - Navigate
  
  public func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .splashIsRequired:
      return self.navigateToSplash()

    case .authIsRequired:
      return self.navigateToAuth()

    case .tabBarIsRequired:
      return self.navigateToDashboard()
      
    default:
      return .none
    }
  }
}

private extension AppFlow {
  func navigateToSplash() -> FlowContributors {
    let splashVC = SplashViewController()

    DispatchQueue.main.async {
      self.rootViewController.pushViewController(splashVC, animated: true)
    }
    
    return .one(flowContributor: .contribute(
      withNextPresentable: splashVC, withNextStepper: splashVC))
  }

  func navigateToDashboard() -> FlowContributors {
    let dashboardFlow = DashboardFlow()

    return .one(flowContributor: .contribute(
      withNextPresentable: dashboardFlow,
      withNextStepper: OneStepper(
        withSingleStep: AppStep.tabBarIsRequired
      )
    ))
  }
  
  func navigateToAuth() -> FlowContributors {
    let authFlow = AuthFlow()
    
    return .one(flowContributor: .contribute(
      withNextPresentable: authFlow,
      withNextStepper: OneStepper(
        withSingleStep: AppStep.authIsRequired
      )
    ))
  }
}

// MARK: - Privates

private extension AppFlow {
  func fetchAppleCredentialState() {
    let appleIDProvider = ASAuthorizationAppleIDProvider()
    guard let userID = try? self.keychain.get(account: KeychainManager.Accounts.userID.rawValue) else { return }
    let decodedUserID = String(decoding: userID, as: UTF8.self)
    appleIDProvider.getCredentialState(forUserID: decodedUserID) { state, _ in
      switch state {
      case .authorized:
        print("Authorized")
      case .notFound, .revoked:
        print("Need re-auth")
      case .transferred:
        break
      @unknown default:
        fatalError()
      }
    }
  }
}
