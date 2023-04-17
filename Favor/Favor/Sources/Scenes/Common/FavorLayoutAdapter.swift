//
//  FavorCompositionalLayoutAdapter.swift
//  Favor
//
//  Created by 이창준 on 2023/04/17.
//

import UIKit

import RxDataSources

protocol Adaptive {
  var item: FavorCompositionalLayout.Item { get }
  var group: FavorCompositionalLayout.Group { get }
  var section: FavorCompositionalLayout.Section { get }
}

class FavorLayoutAdapter<Section> where Section: SectionModelType, Section: Adaptive {

  // MARK: - Properties

  private var dataSource: RxCollectionViewSectionedReloadDataSource<Section>

  // MARK: - Initializer

  init(dataSource: RxCollectionViewSectionedReloadDataSource<Section>) {
    self.dataSource = dataSource
  }

  // MARK: - Functions

  public func build() -> UICollectionViewCompositionalLayout {
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
      configuration: UICollectionViewCompositionalLayoutConfiguration()
    )

    // TODO: Section Spacing

    // TODO: Collection Header & Footer

    return layout
  }
}
