//
//  TermSection.swift
//  Favor
//
//  Created by 이창준 on 2023/03/02.
//

import RxDataSources

struct TermSection {
  var items: [Item]
}

extension TermSection: SectionModelType {
  typealias Item = Terms

  init(original: TermSection, items: [Item]) {
    self = original
    self.items = items
  }
}
