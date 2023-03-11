//
//  d.swift
//  Favor
//
//  Created by 김응철 on 2023/03/04.
//

import UIKit

extension UICollectionViewCompositionalLayout {
  
  /// CompositionalLayout을 사용하는 CollectionView에서 적용되는 Group 객체를 생성합니다.
  /// - Parameters:
  ///   - direction: 그룹이 정렬되는 방향
  ///   - layoutSize: 그룹의 크기
  ///   - subItem: 그룹을 구성하는 CompositionalItem
  ///   - count: subItem의 개수
  static func group(
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

  enum BoundarySupplementaryItemType {
    case header, footer
  }

  /// CompositionalLayout을 사용하는 CollectionView에서 적용되는 헤더/푸터 객체를 생성합니다.
  /// - Parameters:
  ///   - layoutSize: 헤더/푸터의 크기
  ///   - kind: 헤더/푸터를 식별하기 위한 ElementKind
  ///   - type: 헤더/푸터 선택 (`.header`, `.footer`)
  static func supplementary(
    _ type: BoundarySupplementaryItemType,
    layoutSize: NSCollectionLayoutSize,
    kind: String
  ) -> NSCollectionLayoutBoundarySupplementaryItem {
    let alignment: NSRectAlignment = (type == .header) ? .top : .bottom
    return NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: layoutSize,
      elementKind: kind,
      alignment: alignment
    )
  }
}
