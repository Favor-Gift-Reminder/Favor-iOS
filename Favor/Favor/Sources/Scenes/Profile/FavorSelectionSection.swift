//
//  FavorSelectionSection.swift
//  Favor
//
//  Created by 이창준 on 2023/02/24.
//

import RxDataSources

struct FavorSelectionSection {
  var header: String
  var items: [Item]
}

extension FavorSelectionSection: SectionModelType {
  typealias Item = ProfilePreferenceCellReactor

  init(original: FavorSelectionSection, items: [Item]) {
    self = original
    self.items = items
  }
}
