//
//  GiftDetailSection.swift
//  Favor
//
//  Created by 이창준 on 2023/05/25.
//

import UIKit

import Composer
import FavorKit

// MARK: - Item

public enum GiftDetailSectionItem: ComposableItem {
  case image(UIImage?)
  case title
  case tags
  case memo
}

// MARK: - Section

public enum GiftDetailSection: ComposableSection {
  case image
  case title
  case tags
  case memo
}

// MARK: - Hashable

extension GiftDetailSectionItem {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case let (.image(lhsImage), .image(rhsImage)):
      return lhsImage == rhsImage
    default:
      return false
    }
  }

  public func hash(into hasher: inout Hasher) {
    switch self {
    case .image(let image):
      hasher.combine(image)
    case .title:
      hasher.combine("title")
    case .tags:
      hasher.combine("tags")
    case .memo:
      hasher.combine("memo")
    }
  }
}

// MARK: - Composable

extension GiftDetailSection: Composable {
  public var item: UICollectionViewComposableLayout.Item {
    switch self {
    case .image, .title, .tags:
      return .full()
    case .memo:
      return .listRow(height: .estimated(60))
    }
  }

  public var group: UICollectionViewComposableLayout.Group {
    switch self {
    case .image:
      return .singleFullList(height: .absolute(330))
    case .title:
      return .singleFullList(height: .absolute(60))
    case .tags:
      return .singleFullList(height: .absolute(32))
    case .memo:
      return .singleFullList(height: .estimated(60))
    }
  }
  
  public var section: UICollectionViewComposableLayout.Section {
    switch self {
    case .image:
      return .base(
        orthogonalScrolling: .groupPaging,
        boundaryItems: [.footer(height: .absolute(0.01))]
      )
    case .title, .tags:
      return .base(
        contentInsets: NSDirectionalEdgeInsets(top: .zero, leading: 20, bottom: .zero, trailing: 20)
      )
    case .memo:
      return .base(
        contentInsets: NSDirectionalEdgeInsets(top: 6, leading: 20, bottom: .zero, trailing: 20)
      )
    }
  }
}

// MARK: - Sendable

extension GiftDetailSection: Sendable {

}

extension GiftDetailSectionItem: Sendable {
  
}
