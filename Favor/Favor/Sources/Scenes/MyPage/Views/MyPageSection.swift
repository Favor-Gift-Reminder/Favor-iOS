//
//  MyPageSection.swift
//  Favor
//
//  Created by 이창준 on 2023/02/12.
//

import RxDataSources

enum MyPageSectionItem {
  case giftCount
  case newProfile
  case favor
  case anniversary
}

enum MyPageSection {
  case giftCount([MyPageSectionItem])
  case newProfile([MyPageSectionItem])
  case favor([MyPageSectionItem])
  case anniversary([MyPageSectionItem])
}

extension MyPageSection: SectionModelType {
  typealias Item = MyPageSectionItem
  
  var items: [MyPageSectionItem] {
    switch self {
    case .giftCount(let items):
      return items
    case .newProfile(let items):
      return items
    case .favor(let items):
      return items
    case .anniversary(let items):
      return items
    }
  }
  
  init(original: MyPageSection, items: [MyPageSectionItem]) {
    switch original {
    case .giftCount:
      self = .giftCount(items)
    case .newProfile:
      self = .newProfile(items)
    case .favor:
      self = .favor(items)
    case .anniversary:
      self = .anniversary(items)
    }
  }
}
