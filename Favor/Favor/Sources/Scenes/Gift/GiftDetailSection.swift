//
//  GiftDetailSection.swift
//  Favor
//
//  Created by 이창준 on 2023/05/25.
//

import UIKit

import FavorKit

// MARK: - Item

public enum GiftDetailSectionItem: SectionModelItem {
  case image(UIImage?)
  case title
  case tags
  case memo
}

// MARK: - Section

public enum GiftDetailSection: SectionModelType {
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

// MARK: - Adaptive

extension GiftDetailSection: Adaptive {
  public var item: FavorCompositionalLayout.Item {
    return .full()
  }

  public var group: FavorCompositionalLayout.Group {
    switch self {
    case .image:
      return .grid(height: .absolute(330), numberOfItems: 1)
    case .title:
      return .grid(height: .absolute(60), numberOfItems: 1)
    case .tags:
      return .grid(height: .absolute(32), numberOfItems: 1)
    case .memo:
      return .grid(height: .estimated(60), numberOfItems: 1)
    }
  }

  public var section: FavorCompositionalLayout.Section {
    switch self {
    case .image:
      return .base(orthogonalScrolling: .groupPaging)
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
