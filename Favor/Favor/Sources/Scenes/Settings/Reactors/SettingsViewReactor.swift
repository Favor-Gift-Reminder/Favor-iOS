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
    case itemSelected(SettingsSectionItem)
    case switchDidToggled(UserDefaultsKey, to: Bool)
    case doNothing
  }

  public enum Mutation {
    case updateItems(SettingsRenderer)
  }

  public struct State {
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

    case .itemSelected(let item):
      if let step = item.step {
        self.steps.accept(step)
      }
      return .empty()

    case let .switchDidToggled(key, isOn):
      return self.toggleUserDefaults(key, to: isOn)

    case .doNothing:
      return .empty()
    }
  }

  public func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
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
        self.steps.accept(AppStep.localAuthIsRequired(.authenticate(resultHandler)))
      }
    case .isBiometricAuthEnabled:
      UserInfoStorage.isBiometricAuthEnabled = isOn
    case .isReminderNotificationEnabled:
      UserInfoStorage.isReminderNotificationEnabled = isOn
    case .isMarketingNotificationEnabled:
      UserInfoStorage.isMarketingNotificationEnabled = isOn
    default:
      break
    }
    return .empty()
  }
}
