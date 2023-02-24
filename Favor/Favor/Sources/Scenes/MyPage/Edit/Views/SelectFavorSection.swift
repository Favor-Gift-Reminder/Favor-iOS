//
//  SelectFavorSection.swift
//  Favor
//
//  Created by 이창준 on 2023/02/24.
//

import RxDataSources

struct SelectFavorSection {
  var header: String
  var items: [Item]
}

extension SelectFavorSection: SectionModelType {
  typealias Item = FavorCellReactor

  init(original: SelectFavorSection, items: [FavorCellReactor]) {
    self = original
    self.items = items
  }
}
