//
//  RecentSearch.swift
//  Favor
//
//  Created by 이창준 on 6/6/23.
//

import Foundation

import FavorKit
import class RealmSwift.ThreadSafe

public struct RecentSearch: Storable {

  // MARK: - Properties

  public let identifier: Int
  public let query: String
  public var date: Date

  // MARK: - Storable

  public init(realmObject: RecentSearchObject) {
    @ThreadSafe var rlmObjectRef = realmObject
    guard let realmObject = rlmObjectRef else { fatalError() }

    self.identifier = Int(Date().timeIntervalSince1970) % Int.max
    self.query = realmObject.query
    self.date = realmObject.date
  }

  public func realmObject() -> RecentSearchObject {
    RecentSearchObject(
      query: self.query,
      date: self.date
    )
  }
}

// MARK: - Hashable

extension RecentSearch: Hashable {
  public static func == (lhs: RecentSearch, rhs: RecentSearch) -> Bool {
    return lhs.query == rhs.query
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.query)
  }
}

// MARK: - PropertyType

extension RecentSearch {
  public enum PropertyValue: PropertyValueType {
    case query(String)
    case date(Date)

    public var propertyValuePair: PropertyValuePair {
      switch self {
      case .query(let query):
        return ("query", query)
      case .date(let date):
        return ("date", date)
      }
    }
  }
}
