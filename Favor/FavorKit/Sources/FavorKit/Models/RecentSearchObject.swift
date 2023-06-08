//
//  RecentSearchObject.swift
//  Favor
//
//  Created by 이창준 on 2023/04/11.
//

import Foundation

import RealmSwift

public class RecentSearchObject: Object {

  // MARK: - Properties

  @Persisted(primaryKey: true) public var query: String
  @Persisted public var date: Date

  // MARK: - Initializer

  public convenience init(query: String, date: Date) {
    self.init()
    self.query = query
    self.date = date
  }
}
