//
//  FavorCompositionalLayout.swift
//  Favor
//
//  Created by 이창준 on 2023/04/16.
//

import UIKit

final class FavorCompositionalLayout: UICollectionViewCompositionalLayout {

  // MARK: - Item

  /// Item의 타입과 그에 따른 값들을 정의해둔 enum입니다.
  public enum Item {

    /// List의 형태처럼 가로로 꽉 찬 형태의 Item입니다.
    /// - Parameters:
    ///   - height: Item의 `heightDimension`
    ///   - contentInsets: Item의 내부 `NSDirectionalEdgeInsets`
    case listRow(
      height: NSCollectionLayoutDimension,
      contentInsets: NSDirectionalEdgeInsets? = nil
    )

    /// 개별 크기의 사이즈를 가진 형태의 Item입니다.
    /// - Parameters:
    ///   - width: Item의 `widthDimension`
    ///   - height: Item의 `heightDimension`
    ///   - contentInsets: Item의 `NSDirectionalEdgeInsets`
    case grid(
      width: NSCollectionLayoutDimension,
      height: NSCollectionLayoutDimension,
      contentInsets: NSDirectionalEdgeInsets? = nil
    )

    /// 각 enum값의 파라미터들에 더 쉽게 접근하기 위한 wrapper-property
    private var layoutParameters: (
      size: NSCollectionLayoutSize,
      contentInsets: NSDirectionalEdgeInsets
    ) {
      switch self {
      case let .listRow(height, contentInsets):
        return (
          size: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: height
          ),
          contentInsets: contentInsets ?? .zero
        )
      case let .grid(width, height, contentInsets):
        return (
          size: NSCollectionLayoutSize(
            widthDimension: width,
            heightDimension: height
          ),
          contentInsets: contentInsets ?? .zero
        )
      }
    }

    /// 실제 사용될 Item을 만들어 반환해주는 Maker
    /// - Returns: `NSCollectionLayoutItem`
    public func make() -> NSCollectionLayoutItem {
      let item = NSCollectionLayoutItem(
        layoutSize: self.layoutParameters.size
      )

      item.contentInsets = self.layoutParameters.contentInsets

      return item
    }
  }

  // MARK: - Group

  /// Group의 타입과 그에 따른 값들을 정의해둔 enum입니다.
  public enum Group {

    /// Nested Group이라면 가장 상위에 있는 Group
    /// - Parameters:
    ///   - height: Group의 `heightDimension`
    ///   - spacing: Group 내부에 들어있는 Item들의 간격 (`NSCollectionLayoutSpacing`)
    ///   - contentInsets: Group의 내부 `NSDirectionalEdgeInsets`
    case container(
      height: NSCollectionLayoutDimension,
      spacing: NSCollectionLayoutSpacing? = nil,
      contentInsets: NSDirectionalEdgeInsets? = nil
    )

    /// 화면의 너비를 꽉 채우며 가로로 나열되는 아이템들을 담는 Group
    /// -  Parameters:
    ///   - height: Group의 `heightDimension`
    ///   - numberOfItems: Group 안에 포함된 Item들의 개수 (`Int`)
    ///   - spacing: Group 내부에 들어있는 Item들의 간격 (`NSCollectionLayoutSpacing`)
    ///   - contentInsets: Group의 내부 `NSDirectionalEdgeInsets`
    case flow(
      height: NSCollectionLayoutDimension,
      numberOfItems: Int,
      spacing: NSCollectionLayoutSpacing? = nil,
      contentInsets: NSDirectionalEdgeInsets? = nil
    )

    /// 화면의 너비를 꽉 채우며 세로로 나열되는 아이템들을 담는 Group
    /// - Parameters:
    ///   - height: Group의 `heightDimension`
    ///   - numberOfItems: Group 안에 포함된 Item들의 개수 (`Int`)
    ///   - spacing: Group 내부에 들어있는 Item들의 간격 (`NSCollectionLayoutSpacing`)
    ///   - contentInsets: Group의 내부 `NSDirectionalEdgeInsets`
    case list(
      height: NSCollectionLayoutDimension,
      numberOfItems: Int,
      spacing: NSCollectionLayoutSpacing? = nil,
      contentInsets: NSDirectionalEdgeInsets? = nil
    )

    /// 모든 레이아웃 크기를 직접 설정하여 사용하는 Group
    /// - Parameters:
    ///   - width: Group의 `widthDimension`
    ///   - height: Group의 `heightDimension`
    ///   - direction: Group의 아이템들이 정렬되는 방향 (`UICollectionView.ScrollDirection`)
    ///   - numberOfItems: Group 안에 포함된 Item들의 개수 (`Int`)
    ///   - spacing: Group 내부에 들어있는 Item들의 간격 (`NSCollectionLayoutSpacing`)
    ///   - contentInsets: Group의 내부 `NSDirectionalEdgeInsets`
    case contents(
      width: NSCollectionLayoutDimension,
      height: NSCollectionLayoutDimension,
      direction: UICollectionView.ScrollDirection,
      numberOfItems: Int,
      spacing: NSCollectionLayoutSpacing? = nil,
      contentInsets: NSDirectionalEdgeInsets? = nil
    )

    /// 각 enum값의 파라미터들에 더 쉽게 접근하기 위한 wrapper-property
    private var layoutParameters: (
      size: NSCollectionLayoutSize,
      numberOfItems: Int,
      direction: UICollectionView.ScrollDirection,
      spacing: NSCollectionLayoutSpacing,
      contentInsets: NSDirectionalEdgeInsets
    ) {
      switch self {
      case let .container(height, spacing, contentInsets):
        return (
          size: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: height
          ),
          numberOfItems: 1,
          direction: .horizontal,
          spacing: spacing ?? .fixed(.zero),
          contentInsets: contentInsets ?? .zero
        )
      case let .flow(height, numberOfItems, spacing, contentInsets):
        return (
          size: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: height
          ),
          numberOfItems: numberOfItems,
          direction: .horizontal,
          spacing: spacing ?? .fixed(.zero),
          contentInsets: contentInsets ?? .zero
        )
      case let .list(height, numberOfItems, spacing, contentInsets):
        return (
          size: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: height
          ),
          numberOfItems: numberOfItems,
          direction: .vertical,
          spacing: spacing ?? .fixed(.zero),
          contentInsets: contentInsets ?? .zero
        )
      case let .contents(width, height, direction, numberOfItems, spacing, contentInsets):
        return (
          size: NSCollectionLayoutSize(
            widthDimension: width,
            heightDimension: height
          ),
          numberOfItems: numberOfItems,
          direction: direction,
          spacing: spacing ?? .fixed(.zero),
          contentInsets: contentInsets ?? .zero
        )
      }
    }

    /// 실제 사용될 Group을 만들어 반환해주는 Maker
    /// - Returns: `NSCollectionLayoutGroup`
    public func make(
      with item: NSCollectionLayoutItem
    ) -> NSCollectionLayoutGroup {
      let groupMaker = FavorCompositionalLayout.groupForAllVersions(direction: self.layoutParameters.direction)
      let group = groupMaker(self.layoutParameters.size, item, self.layoutParameters.numberOfItems)

      group.interItemSpacing = self.layoutParameters.spacing
      group.contentInsets = self.layoutParameters.contentInsets

      return group
    }
  }

  // MARK: - Section

  /// Section의 타입과 그에 따른 값들을 정의해둔 enum입니다.
  public enum Section {

    /// 기본적으로 사용되는 Section
    /// - Parameters:
    ///   - spacing: Section 내부에 들어있는 Group의 간격 (`CGFloat`)
    ///   - contentInsets: Section의 내부 `NSDirectionalEdgeInsets`
    ///   - orthogonalScrolling: Section이 스크롤되는 방식 (`OrthogonalScrollingBehavior`)
    ///   - boundaryItems: Section의 Header나 Footer (`[BoundaryItem]`)
    case base(
      spacing: CGFloat? = nil,
      contentInsets: NSDirectionalEdgeInsets? = nil,
      orthogonalScrolling: UICollectionLayoutSectionOrthogonalScrollingBehavior? = nil,
      boundaryItems: [BoundaryItem]? = nil
    )

    /// 각 enum값의 파라미터들에 더 쉽게 접근하기 위한 wrapper-property
    private var layoutParameters: (
      spacing: CGFloat,
      contentInsets: NSDirectionalEdgeInsets,
      orthogonalScrolling: UICollectionLayoutSectionOrthogonalScrollingBehavior,
      boundaryItems: [BoundaryItem]
    ) {
      switch self {
      case let .base(spacing, contentInsets, orthogonalScrolling, boundaryItems):
        return (
          spacing: spacing ?? .zero,
          contentInsets: contentInsets ?? .zero,
          orthogonalScrolling: orthogonalScrolling ?? .none,
          boundaryItems: boundaryItems ?? []
        )
      }
    }

    /// 실제 사용될 Section을 만들어 반환해주는 Maker
    /// - Returns: `NSCollectionLayoutSection`
    public func make(
      with group: NSCollectionLayoutGroup
    ) -> NSCollectionLayoutSection {
      let section = NSCollectionLayoutSection(group: group)

      section.interGroupSpacing = self.layoutParameters.spacing
      section.contentInsets = self.layoutParameters.contentInsets
      section.orthogonalScrollingBehavior = self.layoutParameters.orthogonalScrolling
      section.boundarySupplementaryItems = self.layoutParameters.boundaryItems.map { $0.make() }

      return section
    }
  }

  // MARK: - Boundary Item (Header & Footer)

  /// Header와 Footer로 쓰이는 BoundarySupplementaryItem의 타입과 그에 따른 값들을 정의해둔 enum입니다.
  public enum BoundaryItem {

    /// Section의 상단에 위치하는 Header
    /// - Parameters:
    ///   - height: Header의 `HeightDimension`
    ///   - kind: Header의 `elementKind` (`String`)
    ///   - alignment: Header의 위치 (`NSRectAlignment`)
    case header(
      height: NSCollectionLayoutDimension,
      kind: String = UICollectionView.elementKindSectionHeader,
      alignment: NSRectAlignment = .top
    )

    /// Section의 하단에 위치하는 Footer
    /// - Parameters:
    ///   - height: Footer의 `HeightDimension`
    ///   - kind: Footer의 `elementKind` (`String`)
    ///   - alignment: Footer의 위치 (`NSRectAlignment`)
    case footer(
      height: NSCollectionLayoutDimension,
      kind: String = UICollectionView.elementKindSectionFooter,
      alignment: NSRectAlignment = .bottom
    )

    /// 각 enum값의 파라미터들에 더 쉽게 접근하기 위한 wrapper-property
    private var layoutParameters: (
      size: NSCollectionLayoutSize,
      kind: String,
      alignment: NSRectAlignment
    ) {
      switch self {
      case let .header(height, kind, alignment):
        return (
          size: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: height
          ),
          kind: kind,
          alignment: alignment
        )
      case let .footer(height, kind, alignment):
        return (
          size: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: height
          ),
          kind: kind,
          alignment: alignment
        )
      }
    }

    /// 실제 사용될 Boundary Item을 만들어 반환해주는 Maker
    /// - Returns: `NSCollectionLayoutBoundarySupplementaryItem`
    public func make() -> NSCollectionLayoutBoundarySupplementaryItem {
      return NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: self.layoutParameters.size,
        elementKind: self.layoutParameters.kind,
        alignment: self.layoutParameters.alignment
      )
    }
  }

  // MARK: - Functions

}

// MARK: - Privates

private extension FavorCompositionalLayout {
  static func groupForAllVersions(
    direction: UICollectionView.ScrollDirection
  ) -> ((NSCollectionLayoutSize, NSCollectionLayoutItem, Int) -> NSCollectionLayoutGroup) {
    switch direction {
    case .vertical:
      if #available(iOS 16.0, *) {
        return NSCollectionLayoutGroup.vertical(layoutSize:repeatingSubitem:count:)
      } else {
        return NSCollectionLayoutGroup.vertical(layoutSize:subitem:count:)
      }
    case .horizontal:
      if #available(iOS 16.0, *) {
        return NSCollectionLayoutGroup.horizontal(layoutSize:repeatingSubitem:count:)
      } else {
        return NSCollectionLayoutGroup.horizontal(layoutSize:subitem:count:)
      }
    @unknown default:
      fatalError()
    }
  }
}
