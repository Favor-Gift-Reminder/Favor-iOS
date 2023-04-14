//
//  SearchGiftResultSection.swift
//  Favor
//
//  Created by 이창준 on 2023/04/14.
//

import Foundation

import RxDataSources

struct SearchGiftResultSection {
  typealias SearchGiftResultModel = SectionModel<Int, SearchGiftResultItem>

  enum SearchGiftResultItem {
    case gift(SearchGiftResultCellReactor)
  }
}
