//
//  SettingsSection.swift
//  Favor
//
//  Created by 이창준 on 6/28/23.
//

import UIKit

import Composer

// MARK: - Item

public enum SettingsSectionItem: ComposableItem {
  case selectable(SettingsSection, AppStep, title: String, info: String? = nil)
  case switchable(SettingsSection, AppStep, title: String)
  case info(SettingsSection, AppStep, title: String, info: String)
}

// MARK: - Section

public enum SettingsSection: ComposableSection {
  case userInfo
  case notification
  case appInfo
}

// MARK: - Properties

extension SettingsSection {
  public var header: String {
    switch self {
    case .userInfo: return "내 정보"
    case .notification: return "알림"
    case .appInfo: return "앱 정보"
    }
  }
}

// MARK: - Hashable

extension SettingsSectionItem: Hashable {
  public static func == (lhs: SettingsSectionItem, rhs: SettingsSectionItem) -> Bool {
    switch (lhs, rhs) {
    case let (.selectable(_, _, lhsTitle, lhsInfo), .selectable(_, _, rhsTitle, rhsInfo)):
      return lhsTitle == rhsTitle && lhsInfo == rhsInfo
    case let (.switchable(_, _, lhsTitle), .switchable(_, _, rhsTitle)):
      return lhsTitle == rhsTitle
    case let (.info(_, _, lhsTitle, lhsInfo), .info(_, _, rhsTitle, rhsInfo)):
      return lhsTitle == rhsTitle && lhsInfo == rhsInfo
    default:
      return false
    }
  }

  public func hash(into hasher: inout Hasher) {
    switch self {
    case let .selectable(_, _, title, info):
      hasher.combine(title)
      hasher.combine(info)
    case let .switchable(_, _, title):
      hasher.combine(title)
    case let .info(_, _, title, info):
      hasher.combine(title)
      hasher.combine(info)
    }
  }
}

// MARK: - Composer

extension SettingsSection: Composable {
  public var item: UICollectionViewComposableLayout.Item {
    return .listRow(height: .absolute(48))
  }

  public var group: UICollectionViewComposableLayout.Group {
    return .list(spacing: .fixed(4))
  }

  public var section: UICollectionViewComposableLayout.Section {
    let header: UICollectionViewComposableLayout.BoundaryItem = .header(height: .absolute(17))
    let footer: UICollectionViewComposableLayout.BoundaryItem = .footer(height: .absolute(1))
    return .base(
      contentInsets: NSDirectionalEdgeInsets(top: 24, leading: 12, bottom: 32, trailing: 12),
      boundaryItems: [header, footer]
    )
  }
}
