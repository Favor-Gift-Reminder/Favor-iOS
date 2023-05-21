//
//  DiffableDataSourceSnapshotDifference.swift
//  Favor
//
//  Created by 이창준 on 2023/05/20.
//

import OrderedCollections
import UIKit

// swiftlint:disable generic_type_name
// swiftlint:disable indentation_width
public struct DiffableDataSourceSnapshotDifference<SectionIdentifierType, ItemIdentifierType>
  where SectionIdentifierType: Hashable, SectionIdentifierType: Sendable,
        ItemIdentifierType: Hashable, ItemIdentifierType: Sendable {
  var deletedItems: OrderedDictionary<SectionIdentifierType, Set<ItemIdentifierType>>
  var insertedItems: OrderedDictionary<SectionIdentifierType, Set<ItemIdentifierType>>
}
// swiftlint:enable generic_type_name
// swiftlint:enable indentation_width

// MARK: - Functions

extension DiffableDataSourceSnapshotDifference {
  public var isEmpty: Bool {
    return self.deletedItems.isEmpty && self.insertedItems.isEmpty
  }
}

// MARK: - Print Helper

extension DiffableDataSourceSnapshotDifference: CustomStringConvertible {
  public var description: String {
    let sections = self.insertedItems.keys
    return """

    ➕ Inserted items: \(self.insertedItems.map { "🔑 \($0.key) - 🗳️ \($0.value)" })
    
    ➖ Deleted items: \(self.deletedItems.map { "🔑 \($0.key) - 🗳️ \($0.value)" })

    """
  }
}
