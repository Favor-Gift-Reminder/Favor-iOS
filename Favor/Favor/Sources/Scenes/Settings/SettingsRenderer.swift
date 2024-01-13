//
//  SettingsRenderer.swift
//  Favor
//
//  Created by 이창준 on 7/1/23.
//

import Foundation
import OSLog

import DeviceKit
import FavorKit

public enum SettingsRenderer {
  case settings
  case appPrivacy

  public var items: [SettingsSectionItem] {
    switch self {
    case .settings:
      return self.settings()
    case .appPrivacy:
      return self.appPrivacy()
    }
  }
}

// MARK: - Privates

private extension SettingsRenderer {
  typealias Item = SettingsSectionItem

  func settings() -> [SettingsSectionItem] {
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
    
    let terms = self.fetchTerms()
    
    return [
      Item(type: .navigatable, section: .userInfo, title: "로그인 정보", subtitle: FTUXStorage.authState.rawValue, step: .authInfoIsRequired),
      Item(type: .navigatable, section: .userInfo, title: "비밀번호 변경", step: .newPasswordIsRequired),
      Item(type: .navigatable, section: .userInfo, title: "앱 잠금", step: .appPrivacyIsRequired),
      Item(
        type: .switchable(
          initialValue: UserInfoStorage.isReminderNotificationEnabled,
          .isReminderNotificationEnabled),
        section: .notification,
        title: "리마인더 알림"
      ),
      Item(type: .tappable, section: .appInfo, title: "버전", staticInfo: version),
      Item(type: .navigatable, section: .appInfo, title: "팀", step: .devTeamInfoIsRequired),
      Item(type: .navigatable, section: .appInfo, title: "개발자 응원하기", step: .devTeamSupportIsRequired),
      Item(type: .navigatable, section: .appInfo, title: "서비스 이용약관", step: .serviceUsageTermIsRequired(terms[0].url)),
      Item(type: .navigatable, section: .appInfo, title: "개인정보 처리방침", step: .privateInfoManagementTermIsRequired(terms[1].url))
    ]
  }

  func appPrivacy() -> [SettingsSectionItem] {
    let device = Device.current
    var items: [SettingsSectionItem] = []
    // 암호 사용
    items.append(Item(
      type: .switchable(
        initialValue: UserInfoStorage.isLocalAuthEnabled,
        .isLocalAuthEnabled
      ),
      section: .appPrivacy,
      title: "암호 사용"
    ))
    if UserInfoStorage.isLocalAuthEnabled {
      // 생체 인증
      let biometricAuth: String = "생채 인증 사용"
      items.append(Item(
        type: .switchable(
          initialValue: UserInfoStorage.isBiometricAuthEnabled,
          .isBiometricAuthEnabled
        ),
        section: .appPrivacy,
        title: biometricAuth
      ))

      // 암호 변경
      let resultHandler: ((Data?) throws -> Void) = { data in
        guard let data = data else { return }
        let keychain = KeychainManager()
        try keychain.set(value: data, account: KeychainManager.Accounts.localAuth.rawValue)
      }
      items.append(Item(
        type: .navigatable,
        section: .appPrivacy,
        title: "암호 변경",
        step: .localAuthIsRequired(.askCurrent(resultHandler))
      ))
    }

    return items
  }
  
  func fetchTerms() -> [Terms] {
    typealias JSON = [String: Any]
    
    guard let filePath = Bundle.main.path(forResource: "Term-Info", ofType: "plist") else {
      fatalError("Couldn't find the 'Term-Info.plist' file.")
    }
    
    var terms: JSON = [:]
    do {
      var plistRAW: Data
      if #available(iOS 16.0, *) {
        plistRAW = try Data(contentsOf: URL(filePath: filePath))
      } else {
        plistRAW = try NSData(contentsOfFile: filePath) as Data
      }
      terms = try PropertyListSerialization.propertyList(from: plistRAW, format: nil) as! JSON
    } catch {
      os_log(.error, "\(error)")
    }
    
    var decodedTerms: [Terms] = []
    terms.forEach { term in
      guard
        let value = term.value as? JSON,
        let title = value["Title"] as? String,
        let isRequired = value["Required"] as? Bool,
        let url = value["URL"] as? String,
        let index = value["Index"] as? Int
      else { return }
      
      let term = Terms(title: title, isRequired: isRequired, url: url, index: index)
      decodedTerms.append(term)
    }
    
    return decodedTerms.sorted(by: { $0.index < $1.index })
  }
}
