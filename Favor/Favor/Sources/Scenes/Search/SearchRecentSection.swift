//
//  SearchRecentSection.swift
//  Favor
//
//  Created by 이창준 on 2023/04/12.
//

import Foundation

import RxDataSources

struct SearchRecentSection {
  typealias SearchRecentModel = SectionModel<Int, SearchRecentItem>

  enum SearchRecentItem: Equatable {
    case recent(String)
  }
}
