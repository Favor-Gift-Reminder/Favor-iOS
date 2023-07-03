//
//  SettingsViewReactor.swift
//  Favor
//
//  Created by 이창준 on 6/28/23.
//

import Foundation
import OSLog

import FavorKit
import ReactorKit
import RxCocoa
import RxFlow

@MainActor
public final class SettingsViewReactor: Reactor, Stepper {

  // MARK: - Properties

  public var initialState: State
  public let steps = PublishRelay<Step>()
  private let keychain = KeychainManager()

  public enum Action {
    case viewNeedsLoaded
    case switchMethodsCallableUpdated(Bool)
    case itemSelected(SettingsSectionItem)
    case switchDidToggled(UserDefaultsKey, to: Bool)
    case biometricAuthDidFinish(Bool)
    case doNothing
  }

  public enum Mutation {
    case pulseBiometricAuth
    case updateSwitchMethodsCallable(Bool)
    case updateItems(SettingsRenderer)
  }

  public struct State {
    var switchMethodsCallable: Bool = false
    @Pulse var biometricAuthPulse: Bool = false
    var items: [SettingsSectionItem]
    var renderer: SettingsRenderer
  }

  // MARK: - Initializer

  public init(_ renderer: SettingsRenderer) {
    self.initialState = State(
      items: renderer.items,
      renderer: renderer
    )
  }

  // MARK: - Functions

  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewNeedsLoaded:
      return .just(.updateItems(self.currentState.renderer))

    case .switchMethodsCallableUpdated(let userInteractable):
      return .just(.updateSwitchMethodsCallable(userInteractable))

    case .itemSelected(let item):
      if let step = item.step {
        self.steps.accept(step)
      }
      return .empty()

    case let .switchDidToggled(key, isOn):
      if self.currentState.switchMethodsCallable {
        return self.toggleUserDefaults(key, to: isOn)
      } else {
        return .just(.updateItems(self.currentState.renderer))
      }

    case .biometricAuthDidFinish(let isSucceed):
      return self.handleBiometricAuthResult(isSucceed: isSucceed)

    case .doNothing:
      return .empty()
    }
  }

  public func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .pulseBiometricAuth:
      newState.biometricAuthPulse = true

    case .updateSwitchMethodsCallable(let switchMethodsCallable):
      newState.switchMethodsCallable = switchMethodsCallable

    case .updateItems(let renderer):
      newState.items = renderer.items
    }

    return newState
  }
}

// MARK: - Privates

private extension SettingsViewReactor {
  func toggleUserDefaults(_ key: UserDefaultsKey, to isOn: Bool) -> Observable<Mutation> {
    switch key {
    case .isLocalAuthEnabled:
      if isOn {
        let resultHandler: ((Data?) throws -> Void) = { data in
          guard let data = data else { return }
          try self.keychain.set(value: data, account: KeychainManager.Accounts.localAuth.rawValue)
          UserInfoStorage.isLocalAuthEnabled = true
        }
        self.steps.accept(AppStep.localAuthIsRequired(.askNew(resultHandler)))
      } else {
        let resultHandler: ((Data?) throws -> Void) = { _ in
          try self.keychain.delete(account: KeychainManager.Accounts.localAuth.rawValue)
          UserInfoStorage.isLocalAuthEnabled = false
          UserInfoStorage.isBiometricAuthEnabled = false
        }
        self.steps.accept(AppStep.localAuthIsRequired(.disable(resultHandler)))
      }
    case .isBiometricAuthEnabled:
      if isOn && !UserInfoStorage.isBiometricAuthEnabled {
        return .just(.pulseBiometricAuth)
      } else if !isOn {
        UserInfoStorage.isBiometricAuthEnabled = false
      }
    case .isReminderNotificationEnabled:
      UserInfoStorage.isReminderNotificationEnabled = isOn
    case .isMarketingNotificationEnabled:
      UserInfoStorage.isMarketingNotificationEnabled = isOn
    default:
      break
    }
    return .empty()
  }

  func handleBiometricAuthResult(isSucceed: Bool) -> Observable<Mutation> {
    let isSucceedString: String = isSucceed ? "true" : "false"
    os_log(.debug, "Biometric Auth did finish with result: \(isSucceedString).")
    UserInfoStorage.isBiometricAuthEnabled = isSucceed
    return .just(.updateItems(self.currentState.renderer))
  }
}
