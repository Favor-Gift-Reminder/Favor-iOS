//
//  SearchRecent.swift
//  Favor
//
//  Created by 이창준 on 2023/04/11.
//

import Foundation

import RealmSwift

public class SearchRecent: Object {

  // MARK: - Properties

  @Persisted(primaryKey: true) public var searchText: String
  @Persisted public var searchDate: Date

  // MARK: - Initializer

  public convenience init(searchText: String, searchDate: Date) {
    self.init()
    self.searchText = searchText
    self.searchDate = searchDate
  }
}
