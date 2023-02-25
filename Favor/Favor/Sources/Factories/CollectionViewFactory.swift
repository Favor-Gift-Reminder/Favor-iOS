//
//  CollectionViewFactory.swift
//  Favor
//
//  Created by 이창준 on 2023/02/25.
//

import UIKit

final class CompositionalLayoutFactory {

  class var shared: CompositionalLayoutFactory {
    struct Static {
      static let instance: CompositionalLayoutFactory = CompositionalLayoutFactory()
    }
    return Static.instance
  }

  func makeCompositionalGroup(
    direction: UICollectionView.ScrollDirection,
    layoutSize: NSCollectionLayoutSize,
    subItem: NSCollectionLayoutItem,
    count: Int
  ) -> NSCollectionLayoutGroup {
    var group: NSCollectionLayoutGroup
    if #available(iOS 16.0, *) {
      switch direction {
      case .vertical:
        group = NSCollectionLayoutGroup.vertical(
          layoutSize: layoutSize,
          repeatingSubitem: subItem,
          count: count
        )
      case .horizontal:
        group = NSCollectionLayoutGroup.horizontal(
          layoutSize: layoutSize,
          repeatingSubitem: subItem,
          count: count
        )
      @unknown default:
        fatalError("Unknown Direction.")
      }
    } else {
      switch direction {
      case .horizontal:
        group = NSCollectionLayoutGroup.horizontal(
          layoutSize: layoutSize,
          subitem: subItem,
          count: count
        )
      case .vertical:
        group = NSCollectionLayoutGroup.vertical(
          layoutSize: layoutSize,
          subitem: subItem,
          count: count
        )
      @unknown default:
        fatalError("Unknown Direction.")
      }
    }
    return group
  }
}
