//
//  NewAnniversarySection.swift
//  Favor
//
//  Created by 이창준 on 2023/02/25.
//

import RxDataSources

struct NewAnniversarySection {
  var header: String
  var items: [Item]
}

extension NewAnniversarySection: SectionModelType {
  typealias Item = ProfileAnniversaryCellReactor

  init(original: NewAnniversarySection, items: [Item]) {
    self = original
    self.items = items
  }
}
