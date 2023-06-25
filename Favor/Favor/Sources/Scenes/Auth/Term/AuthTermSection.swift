//
//  AuthTermSection.swift
//  Favor
//
//  Created by 이창준 on 6/25/23.
//

import UIKit

import Composer

// MARK: - Item

public struct AuthTermSectionItem: ComposableItem {
  public var terms: Terms
}

// MARK: - Section

public enum AuthTermSection: ComposableSection {
  case term
}

// MARK: - Hashable

extension AuthTermSectionItem: Hashable {
  public static func == (lhs: AuthTermSectionItem, rhs: AuthTermSectionItem) -> Bool {
    return lhs.terms == rhs.terms
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.terms)
  }
}

// MARK: - Composer

extension AuthTermSection: Composable {
  public var item: UICollectionViewComposableLayout.Item {
    return .full()
  }

  public var group: UICollectionViewComposableLayout.Group {
    return .singleFullList(height: .absolute(32))
  }

  public var section: UICollectionViewComposableLayout.Section {
    return .base(spacing: 16)
  }
}
