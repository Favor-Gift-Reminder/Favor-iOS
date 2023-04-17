//
//  FavorCompositionalLayout+Adapter.swift
//  Favor
//
//  Created by 이창준 on 2023/04/17.
//

import UIKit

import RxDataSources

open class Adapter<Section> where Section: SectionModelType, Section: Adaptive {

  // MARK: - Properties

  private var dataSource: RxCollectionViewSectionedReloadDataSource<Section>

  // MARK: - Initializer

  public init(dataSource: RxCollectionViewSectionedReloadDataSource<Section>) {
    self.dataSource = dataSource
  }

  // MARK: - Functions

  public func build(
    scrollDirection: UICollectionView.ScrollDirection,
    sectionSpacing: CGFloat? = nil,
    header: FavorCompositionalLayout.BoundaryItem? = nil,
    footer: FavorCompositionalLayout.BoundaryItem? = nil
  ) -> UICollectionViewCompositionalLayout {
    let layoutConfiguration = UICollectionViewCompositionalLayoutConfiguration()
    layoutConfiguration.scrollDirection = scrollDirection
    layoutConfiguration.interSectionSpacing = sectionSpacing ?? .zero
    if let header {
      layoutConfiguration.boundarySupplementaryItems.append(header.make())
    }
    if let footer {
      layoutConfiguration.boundarySupplementaryItems.append(footer.make())
    }

    let layout = UICollectionViewCompositionalLayout(
      sectionProvider: { sectionIndex, _ in
        let sectionType = self.dataSource[sectionIndex]

        // Item
        let item = sectionType.item.make()

        // Group
        let group = sectionType.group.make(with: item)

        // Section
        let section = sectionType.section.make(with: group)

        return section
      },
      configuration: layoutConfiguration
    )

    return layout
  }
}
