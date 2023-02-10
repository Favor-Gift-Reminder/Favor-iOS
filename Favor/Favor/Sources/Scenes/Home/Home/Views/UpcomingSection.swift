//
//  UpcomingSection.swift
//  Favor
//
//  Created by 이창준 on 2023/01/31.
//

import RxDataSources

struct UpcomingSection {
  let header: String
  var items: [Item]
}

extension UpcomingSection: AnimatableSectionModelType {
  typealias Item = String
  
  var identity: String {
    return self.header
  }
  
  init(original: UpcomingSection, items: [Item]) {
    self = original
    self.items = items
  }
}
