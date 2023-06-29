//
//  SettingsAuthInfoSection.swift
//  Favor
//
//  Created by 이창준 on 6/29/23.
//

import UIKit

import Composer

// MARK: - Item

public enum SettingsAuthInfoSectionItem: ComposableItem {

}

// MARK: - Section

public enum SettingsAuthInfoSection: ComposableSection {

}

// MARK: - Composer

extension SettingsAuthInfoSection: Composable {
  public var item: UICollectionViewComposableLayout.Item {
    return .full()
  }

  public var group: UICollectionViewComposableLayout.Group {
    return .full()
  }

  public var section: UICollectionViewComposableLayout.Section {
    return .base()
  }
}
