//
//  NSDiffableDataSourceSnapshot+.swift
//  Favor
//
//  Created by 이창준 on 2023/05/20.
//

import OrderedCollections
import UIKit

extension NSDiffableDataSourceSnapshot {

  /// - Parameters:
  ///   - origin: 비교 대상이 되는 `NSDiffableDataSourceSnapshot`
  public func difference(from origin: Self) -> DiffableDataSourceSnapshotDifference<SectionIdentifierType, ItemIdentifierType> {
    var difference = DiffableDataSourceSnapshotDifference<SectionIdentifierType, ItemIdentifierType>(
      deletedItems: [:],
      insertedItems: [:]
    )

    let originSections = Set(origin.sectionIdentifiers)
    let endpointSections = Set(self.sectionIdentifiers)
    let sections = originSections.union(endpointSections)

    for sectionIdentifier in sections {
      // 이전 snapshot에 이번 snapshot에 있는 section이 없다면 빈 Set
      let originItems = origin.indexOfSection(sectionIdentifier) == nil ?
        Set() :
        Set(origin.itemIdentifiers(inSection: sectionIdentifier))
      // 이번 snapshot에 이전 snapshot에 있던 section이 없다면 빈 Set
      let endpointItems = self.indexOfSection(sectionIdentifier) == nil ?
        Set() :
        Set(self.itemIdentifiers(inSection: sectionIdentifier))

      let deletedItems = originItems.subtracting(endpointItems)
      let insertedItems = endpointItems.subtracting(originItems)

      difference.deletedItems[sectionIdentifier] = deletedItems
      difference.insertedItems[sectionIdentifier] = insertedItems
    }
    
    return difference
  }
}
