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

public final class SettingsViewReactor: Reactor, Stepper {

  // MARK: - Properties

  public var initialState: State
  public let steps = PublishRelay<Step>()

  public enum Action {
    case viewNeedsLoaded
    case itemSelected(SettingsSectionItem)
    case doNothing
  }

  public enum Mutation {
    case updateItems([SettingsSectionItem])
  }

  public struct State {
    var items: [SettingsSectionItem] = []
  }

  // MARK: - Initializer

  init() {
    self.initialState = State()
  }

  // MARK: - Functions

  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewNeedsLoaded:
      return .just(.updateItems(self.setupCells()))

    case .itemSelected(let item):
      switch item {
      case
        let .selectable(_, step, _, _),
        let .switchable(_, step, _),
        let .info(_, step, _, _):
        self.steps.accept(step)
      }
      return .empty()

    case .doNothing:
      return .empty()
    }
  }

  public func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .updateItems(let items):
      newState.items = items
    }

    return newState
  }
}

// MARK: - Privates

private extension SettingsViewReactor {
  func setupCells() -> [SettingsSectionItem] {
    guard
      let info: [String: Any] = Bundle.main.infoDictionary,
      let appVersion = info["CFBundleShortVersionString"] as? String,
      let buildVersion = info["CFBundleVersion"] as? String
    else { return [] }
    let version: String
    if buildVersion == "beta" {
      version = [appVersion, buildVersion].joined(separator: " ")
    } else {
      version = appVersion
    }
    let localAuthLocation: LocalAuthLocation
    if UserInfoStorage.isLocalAuthEnabled {
      localAuthLocation = .settingsCheckOld
    } else {
      localAuthLocation = .settingsNew
    }
    return [
      .selectable(
        .userInfo, .authInfoIsRequired, title: "로그인 정보", info: FTUXStorage.authState.rawValue),
      .selectable(
        .userInfo, .newPasswordIsRequired, title: "비밀번호 변경"),
      .selectable(
        .userInfo, .localAuthIsRequired(localAuthLocation), title: "앱 잠금"),
      .switchable(
        .notification, .doNothing, title: "리마인더 알림"),
      .switchable(
        .notification, .doNothing, title: "마케팅 정보 알림"),
      .info(
        .appInfo, .doNothing, title: "버전", info: version),
      .selectable(
        .appInfo, .devTeamInfoIsRequired, title: "팀"),
      .selectable(
        .appInfo, .devTeamSupportIsRequired, title: "개발자 응원하기"),
      .selectable(
        .appInfo, .serviceUsageTermIsRequired, title: "서비스 이용약관"),
      .selectable(
        .appInfo, .privateInfoManagementTermIsRequired, title: "개인정보 처리방침"),
      .selectable(
        .appInfo, .openSourceUsageIsRequired, title: "오픈 소스 라이선스")
    ]
  }
  
}
