//
//  SettingsSection.swift
//  Favor
//
//  Created by 이창준 on 6/28/23.
//

import UIKit

import Composer
import FavorKit

// MARK: - Item

public struct SettingsSectionItem: ComposableItem {

  // MARK: - Constants

  public enum CellType: Hashable {
    /// 고정된 셀
    case tappable
    /// 선택 시 다른 화면으로 탐색하는 셀
    case navigatable
    /// 선택 시 토글 스위치가 동작하는 셀
    case switchable(initialValue: Bool, UserDefaultsKey)
  }

  // MARK: - Properties

  public var type: CellType
  public var section: SettingsSection
  public var title: String
  public var subtitle: String?
  public var staticInfo: String?
  var step: AppStep?

}

// MARK: - Section

public enum SettingsSection: ComposableSection {
  case userInfo
  case notification
  case appInfo
  case appPrivacy
}

// MARK: - Properties

extension SettingsSection {
  public var index: Int {
    switch self {
    case .userInfo: return 0
    case .notification: return 1
    case .appInfo: return 2
    case .appPrivacy: return 0
    }
  }

  public var header: String? {
    switch self {
    case .userInfo: return "내 정보"
    case .notification: return "알림"
    case .appInfo: return "앱 정보"
    default: return nil
    }
  }
}

// MARK: - Comparable

extension SettingsSection: Comparable {
  
}

// MARK: - Hashable

extension SettingsSectionItem: Hashable {
  public static func == (lhs: SettingsSectionItem, rhs: SettingsSectionItem) -> Bool {
    switch (lhs.type, rhs.type) {
    case let (.switchable(lhsInitialValue, _), .switchable(rhsInitialValue, _)):
      return lhs.title == rhs.title && lhsInitialValue != rhsInitialValue
    default:
      return lhs.title == rhs.title
    }
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.title)
  }
}

// MARK: - Composer

extension SettingsSection: Composable {
  public var item: UICollectionViewComposableLayout.Item {
    return .listRow(height: .absolute(56))
  }

  public var group: UICollectionViewComposableLayout.Group {
    return .list(spacing: .fixed(4))
  }

  public var section: UICollectionViewComposableLayout.Section {
    let header: UICollectionViewComposableLayout.BoundaryItem = .header(height: .absolute(17))
    let footer: UICollectionViewComposableLayout.BoundaryItem = .footer(height: .absolute(1))
    let boundaryItems: [UICollectionViewComposableLayout.BoundaryItem]
    switch self {
    case .userInfo, .notification, .appInfo:
      boundaryItems = [header, footer]
    case .appPrivacy:
      boundaryItems = []
    }
    return .base(
      contentInsets: NSDirectionalEdgeInsets(top: 24, leading: 12, bottom: 32, trailing: 12),
      boundaryItems: boundaryItems
    )
  }
}
